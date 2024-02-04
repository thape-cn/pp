class StaffNeedConfirmRemindWecomJob
  include Sidekiq::Job

  def perform(company_evaluation_id, clerk_code)
    need_confirm_evaluation_template_ids = CompanyEvaluationTemplate
      .where(company_evaluation_id: company_evaluation_id).pluck(:id)
    need_confirm_user_ids = User.where(clerk_code: clerk_code, is_active: true).pluck(:id)

    EvaluationUserCapability.where(company_evaluation_template_id: need_confirm_evaluation_template_ids,
      user_id: need_confirm_user_ids).each do |evaluation_user_capability|
      next unless evaluation_user_capability.form_status == "hr_review_completed"

      ConfirmEvaluationUserCapabilityMailer.with(evaluation_user_capability: evaluation_user_capability).notification_email.deliver_now
    end
  end
end
