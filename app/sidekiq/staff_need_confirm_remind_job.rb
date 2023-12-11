class StaffNeedConfirmRemindJob
  include Sidekiq::Job

  def perform(wecom_id, evaluation_user_capability_id)
    sent_message = <<~HELLO
      【绩效评价通知】
      请尽快登录绩效系统，确认并查看绩效评价
      登录链接：https://performance.thape.com.cn/staff/signing/#{evaluation_user_capability_id}
    HELLO

    Wechat.api.custom_message_send Wechat::Message.to(wecom_id).text(sent_message)
  rescue Wechat::ResponseError => e
    Rails.logger.error("Failed to send staff need confirm remind message to wecom_id: #{wecom_id}. Error: #{e.message}")
  end
end
