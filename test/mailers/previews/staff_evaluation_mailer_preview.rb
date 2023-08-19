# Preview all emails at http://localhost:3000/rails/mailers/staff_evaluation_mailer
class StaffEvaluationMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/staff_evaluation_mailer/start
  def start
    StaffEvaluationMailer.with(evaluation_user_capability: EvaluationUserCapability.find(42)).start
  end
end
