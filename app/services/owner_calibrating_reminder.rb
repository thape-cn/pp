# frozen_string_literal: true

class OwnerCalibratingReminder
  def initialize
    @need_sending_calibration_sessions = []
  end

  def collect_need_sending_calibrating_remind(calibration_session)
    all_evaluation_user_capabilities = calibration_session.calibration_session_users.collect(&:evaluation_user_capability)
    no_any_new_calibration_session = !calibration_session.calibration_session_users.any? { |csu| csu.new_calibration_session_id.present? }
    eucs_all_in_manager_scored = all_evaluation_user_capabilities.all? { |euc| euc.form_status == "manager_scored" }
    if no_any_new_calibration_session && eucs_all_in_manager_scored
      @need_sending_calibration_sessions << calibration_session
    end
  end

  def send_calibrating_remind_messages
    @need_sending_calibration_sessions.each do |calibration_session|
      owner_user = calibration_session.owner
      wecom_id = owner_user.wecom_id.present? ? owner_user.wecom_id : owner_user.email.split("@")[0]
      OwnerNeedCalibratingRemindJob.perform_async(wecom_id)
    end
  end
end
