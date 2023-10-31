# frozen_string_literal: true

class OwnerCalibratingReminder
  def initialize
    @need_sending_calibration_sessions = []
  end

  def collect_need_sending_calibrating_remind(calibration_session)
    if calibration_session.can_sending_calibrating_remind?
      @need_sending_calibration_sessions << calibration_session
    end
  end

  def send_calibrating_remind_messages
    need_sending_calibration_owners.each do |owner_user|
      wecom_id = owner_user.wecom_id.present? ? owner_user.wecom_id : owner_user.email.split("@")[0]
      OwnerNeedCalibratingRemindJob.perform_async(wecom_id)
    end
  end

  private

  def need_sending_calibration_owners
    need_check_owners = @need_sending_calibration_sessions.compact.collect(&:owner).compact
    need_sending_calibration_owners = []
    need_check_owners.each do |owner|
      if owner.owned_calibration_sessions.all? { |cs| cs.can_sending_calibrating_remind? }
        need_sending_calibration_owners << owner
      end
    end
    need_sending_calibration_owners.compact
  end
end
