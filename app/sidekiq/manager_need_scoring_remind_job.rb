class ManagerNeedScoringRemindJob
  include Sidekiq::Job

  def perform(wecom_id)
    sent_message = <<~HELLO
      【绩效评价通知】
      您的所有下属已经全部完成了自评，请尽快登录绩效系统为下属评分。
      登录链接：https://performance.thape.com.cn/
    HELLO

    Wechat.api.custom_message_send Wechat::Message.to(wecom_id).text(sent_message)
  end
end
