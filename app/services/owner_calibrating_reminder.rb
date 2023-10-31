# frozen_string_literal: true

class OwnerCalibratingReminder
  def initialize
    @need_sending_calibration_sessions = []
  end

  def collect_need_sending_calibrating_remind(calibration_session)
  end

  def send_calibrating_remind_messages
    @need_sending_calibration_sessions.each do |calibration_session|
      owner_user = calibration_session.owner
      wecom_id = owner_user.wecom_id.present? ? owner_user.wecom_id : owner_user.email.split("@")[0]
      OwnerNeedCalibratingRemindJob.perform_async(wecom_id)
    end
  end
end
