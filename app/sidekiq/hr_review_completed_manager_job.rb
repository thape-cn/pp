class HRReviewCompletedManagerJob
  include Sidekiq::Job

  def perform(calibration_session_id)
    calibration_session = CalibrationSession.find_by(id: calibration_session_id)
    return unless calibration_session.present?

    managers_ids = calibration_session.calibration_session_users.collect { |csu| csu.evaluation_user_capability.manager_user_id }.uniq.reject(&:blank?)

    User.where(id: managers_ids).each do |manager|
      FinalizeCalibrationSessionMailer.with(manager: manager, calibration_session: calibration_session).notification_manager.deliver_now
    end
  end
end
