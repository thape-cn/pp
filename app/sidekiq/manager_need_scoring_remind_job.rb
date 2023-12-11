class ManagerNeedScoringRemindJob
  include Sidekiq::Job

  def perform(wecom_id)
    sent_message = <<~HELLO
      【绩效评价通知】
      您的下属均已完成自评，请尽快登录绩效系统进行上级评价。
      登录链接：https://performance.thape.com.cn/
    HELLO

    Wechat.api.custom_message_send Wechat::Message.to(wecom_id).text(sent_message)
  rescue Wechat::ResponseError => e
    Rails.logger.error("Failed to send manager need scoring remind message to wecom_id: #{wecom_id}. Error: #{e.message}")
  end
end
