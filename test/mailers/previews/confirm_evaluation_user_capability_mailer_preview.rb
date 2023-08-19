# Preview all emails at http://localhost:3000/rails/mailers/confirm_evaluation_user_capability_mailer
class ConfirmEvaluationUserCapabilityMailerPreview < ActionMailer::Preview
  def notification_email
    ConfirmEvaluationUserCapabilityMailer.with(evaluation_user_capability: EvaluationUserCapability.first).notification_email
  end
end
