class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
    :recoverable, :rememberable, :validatable, :trackable

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_many :user_job_roles, dependent: :destroy
  has_many :job_roles, through: :user_job_roles
  has_many :evaluation_user_capabilities
  has_many :hr_user_managed_companies
  has_many :corp_president_managed_companies
  has_many :hrbp_user_managed_departments
  has_many :secretary_managed_departments
  has_many :euc_form_status_histories
  has_many :owned_calibration_sessions, class_name: "CalibrationSession", foreign_key: "owner_id"
  has_many :hr_reviewed_calibration_sessions, class_name: "CalibrationSession", foreign_key: "hr_reviewer_id"
  has_many :calibration_session_judges, foreign_key: "judge_id"
  has_many :calibration_session_users
  has_many :import_excel_files

  normalizes :email, with: ->(email) { email.downcase.strip }

  def name_with_clerk_code
    "#{clerk_code} #{chinese_name}"
  end

  def admin?
    CoreUIsettings.admin.emails.include?(email)
  end

  def hr_staff?
    hr_user_managed_companies.present?
  end

  def corp_president?
    corp_president_managed_companies.present?
  end

  def secretary?
    secretary_managed_departments.present?
  end

  def hr_bp?
    hrbp_user_managed_departments.present?
  end

  def role_ids
    @_role_ids ||= user_roles.collect(&:role_id)
  end

  def role_ids=(values)
    select_values = Array(values).reject(&:blank?).map(&:to_i)
    if new_record?
      (select_values - role_ids).each do |to_new_id|
        user_roles.build(role_id: to_new_id)
      end
    else
      (role_ids - select_values).each do |to_destroy_id|
        user_roles.find_by(role_id: to_destroy_id).destroy
      end
      (select_values - role_ids).each do |to_add_id|
        user_roles.create(role_id: to_add_id)
      end
    end
  end

  def managed_company_names
    @_managed_company_names ||= hr_user_managed_companies.collect(&:managed_company)
  end

  def managed_company_names=(values)
    select_values = Array(values).reject(&:blank?)
    if new_record?
      (select_values - managed_company_names).each do |new_company_name|
        hr_user_managed_companies.build(managed_company: new_company_name)
      end
    else
      (managed_company_names - select_values).each do |to_destroy_company_name|
        hr_user_managed_companies.find_by(managed_company: to_destroy_company_name).destroy
      end
      (select_values - managed_company_names).each do |to_add_company_name|
        hr_user_managed_companies.create(managed_company: to_add_company_name)
      end
    end
  end

  def corp_president_managed_company_names
    @_corp_president_managed_company_names ||= corp_president_managed_companies.collect(&:managed_company)
  end

  def corp_president_managed_company_names=(values)
    select_values = Array(values).reject(&:blank?)
    if new_record?
      (select_values - corp_president_managed_company_names).each do |new_company_name|
        corp_president_managed_companies.build(managed_company: new_company_name)
      end
    else
      (corp_president_managed_company_names - select_values).each do |to_destroy_company_name|
        corp_president_managed_companies.find_by(managed_company: to_destroy_company_name).destroy
      end
      (select_values - corp_president_managed_company_names).each do |to_add_company_name|
        corp_president_managed_companies.create(managed_company: to_add_company_name)
      end
    end
  end

  def hrbp_user_managed_dept_codes
    @_hrbp_user_managed_dept_codes ||= hrbp_user_managed_departments.collect(&:managed_dept_code)
  end

  def hrbp_user_managed_dept_codes=(values)
    select_values = Array(values).reject(&:blank?)
    if new_record?
      (select_values - hrbp_user_managed_dept_codes).each do |new_dept_code|
        hrbp_user_managed_departments.build(managed_dept_code: new_dept_code, auto_managed: false)
      end
    else
      (hrbp_user_managed_dept_codes - select_values).each do |to_destroy_dept_code|
        hrbp_user_managed_departments.find_by(managed_dept_code: to_destroy_dept_code).destroy
      end
      (select_values - hrbp_user_managed_dept_codes).each do |to_add_dept_code|
        hrbp_user_managed_departments.create(managed_dept_code: to_add_dept_code, auto_managed: false)
      end
    end
  end

  def secretary_managed_dept_codes
    @_secretary_managed_dept_codes ||= secretary_managed_departments.collect(&:managed_dept_code)
  end

  def secretary_managed_dept_codes=(values)
    select_values = Array(values).reject(&:blank?)
    if new_record?
      (select_values - secretary_managed_dept_codes).each do |new_dept_code|
        secretary_managed_departments.build(managed_dept_code: new_dept_code)
      end
    else
      (secretary_managed_dept_codes - select_values).each do |to_destroy_dept_code|
        secretary_managed_departments.find_by(managed_dept_code: to_destroy_dept_code).destroy
      end
      (select_values - secretary_managed_dept_codes).each do |to_add_dept_code|
        secretary_managed_departments.create(managed_dept_code: to_add_dept_code)
      end
    end
  end

  # default options of datatables: https://datatables.net/reference/option/lengthMenu
  def self.length_menu_options
    [10, 25, 50, 100]
  end

  def self.system_admin
    find_by!(email: "admin@thape.com.cn")
  end

  def self.user_ids_need_to_skip
    @_user_ids_need_to_skip ||= where("email like 'pptest%@thape.com.cn'")
      .or(where("email like 'hrbp%@thape.com.cn'"))
      .pluck(:id)
  end
end
