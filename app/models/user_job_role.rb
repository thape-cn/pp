class UserJobRole < ApplicationRecord
  belongs_to :user
  belongs_to :job_role
  belongs_to :manager_user, optional: true, class_name: :User

  validates_uniqueness_of :user_id, scope: :job_role_id
  
  def self.all_company_names
    select(:company).distinct.pluck(:company)
  end

  def self.all_dept_codes
    select(:dept_code).distinct.pluck(:dept_code)
  end

  def self.company_by_dept_code
    @company_by_dept_code ||= all.select(:company, :dept_code).distinct.each_with_object({}) do |s, h|
      h[s.dept_code] = s.company
    end
  end

  def self.department_by_dept_code
    @department_by_dept_code ||= all.select(:department, :dept_code).distinct.each_with_object({}) do |s, h|
      h[s.dept_code] = s.department
    end
  end
end
