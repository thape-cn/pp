class OwnerNeedCalibratingRemindJob
  include Sidekiq::Job

  def perform(wecom_id)
    sent_message = <<~HELLO
      【绩效评价通知】
      您的经理均已完成评分，请尽快登录绩效系统进行校准操作。
      登录链接：https://performance.thape.com.cn/
    HELLO

    Wechat.api.custom_message_send Wechat::Message.to(wecom_id).text(sent_message)
  end
end
