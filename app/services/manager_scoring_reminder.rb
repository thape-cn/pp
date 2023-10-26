# frozen_string_literal: true

class ManagerScoringReminder
  def self.need_sending_wechat_message?(evaluation_user_capability)
    false
  end

  def self.send_wechat_message(manager_user)
    wecom_id = manager_user.wecom_id.present? ? manager_user.wecom_id : manager_user.email.split("@")[0]
    ManagerNeedScoringRemindJob.perform_async(wecom_id)
  end
end
