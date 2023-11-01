class OwnerNeedCalibratingRemindJob
  include Sidekiq::Job

  def perform(wecom_id)
    sent_message = <<~HELLO
      【绩效评价通知】
      校准会话已激活，请尽快登录绩效系统进行操作。
      登录链接：https://performance.thape.com.cn/
    HELLO

    Wechat.api.custom_message_send Wechat::Message.to(wecom_id).text(sent_message)
  end
end
