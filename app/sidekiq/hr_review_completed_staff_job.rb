class HRReviewCompletedStaffJob
  include Sidekiq::Job

  def perform(calibration_session_id)
    calibration_session = CalibrationSession.find_by(id: calibration_session_id)
    return unless calibration_session.present?

    calibration_session.calibration_session_users.each do |csu|
      next if csu.new_calibration_session_id.present?

      ConfirmEvaluationUserCapabilityMailer.with(evaluation_user_capability: csu.evaluation_user_capability).notification_email.deliver_now
    end
  end
end
