class SentSelfAssessmentRemindEmailJob
  include Sidekiq::Job

  def perform(company_evaluation_id, clerk_code)
    in_self_assessment_evaluation_template_ids = CompanyEvaluationTemplate
      .where(company_evaluation_id: company_evaluation_id).pluck(:id)
    in_self_assessment_user_ids = User.where(clerk_code: clerk_code, is_active: true).pluck(:id)

    EvaluationUserCapability.where(company_evaluation_template_id: in_self_assessment_evaluation_template_ids,
      user_id: in_self_assessment_user_ids).each do |evaluation_user_capability|
      next unless evaluation_user_capability.form_status == "initial"

      StaffEvaluationMailer.with(evaluation_user_capability: evaluation_user_capability).start.deliver_now
    end
  end
end
