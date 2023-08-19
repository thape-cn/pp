class FinalizeCalibrationSessionMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.finalize_calibration_session_mailer.notification_manager.subject
  #
  def notification_manager
    @manager = params[:manager]
    @calibration_session = params[:calibration_session]

    mail to: get_user_email(@manager), subject: "【绩效评价通知】您的下属绩效等级已定案"
  end
end
