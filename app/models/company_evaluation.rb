class CompanyEvaluation < ApplicationRecord
  has_many :company_evaluation_templates
  validates :title, :start_date, :end_date, presence: true

  scope :open_for_user, -> { where("start_date <= ?", Time.zone.now).where("end_date >= ?", Time.zone.now) }
  scope :closed_for_user, -> { where("end_date < ?", Time.zone.now).order(id: :desc) }

  def remove_leaving_employee_eucs
    open_for_user_company_evaluation_template_ids = CompanyEvaluationTemplate.where(company_evaluation_id: id).pluck(:id)
    EvaluationUserCapability.where(company_evaluation_template_id: open_for_user_company_evaluation_template_ids)
      .where.not(form_status: "data_locked").find_each do |euc|
      next if euc.user.email.start_with?("pptest")
      next if euc.user.is_active
      next if UserJobRole.where(user_id: euc.user_id, job_role_id: euc.job_role_id, is_active: true).exists?

      euc.deleted_user_id = User.system_admin.id
      euc.deleted_reason = "员工离职关闭"
      euc.destroy!
    end
  end
end
