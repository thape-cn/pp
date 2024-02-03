# Preview all emails at http://localhost:3000/rails/mailers/finalize_calibration_session_mailer
class FinalizeCalibrationSessionMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/finalize_calibration_session_mailer/notification_manager
  def notification_manager
    FinalizeCalibrationSessionMailer.with(manager: User.first, calibration_session: CalibrationSession.first).notification_manager
  end
end
