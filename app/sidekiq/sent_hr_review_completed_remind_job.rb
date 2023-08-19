class SentHRReviewCompletedRemindJob
  include Sidekiq::Job

  def perform(company_evaluation_id)
    company_evaluation = CompanyEvaluation.find company_evaluation_id
    hr_review_completed_eucs = EvaluationUserCapability.joins(:company_evaluation_template)
      .where(company_evaluation_template: {company_evaluation_id: company_evaluation.id})
      .where(form_status: "hr_review_completed")
    hr_review_completed_eucs.each do |euc|
      ConfirmEvaluationUserCapabilityMailer.with(evaluation_user_capability: euc).notification_email.deliver_now
    end
  end
end
