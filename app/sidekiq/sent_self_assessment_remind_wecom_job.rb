class SentSelfAssessmentRemindWecomJob
  include Sidekiq::Job

  def perform(company_evaluation_id, clerk_code)
    in_self_assessment_evaluation_template_ids = CompanyEvaluationTemplate
      .where(company_evaluation_id: company_evaluation_id).pluck(:id)
    in_self_assessment_user_ids = User.where(clerk_code: clerk_code, is_active: true).pluck(:id)

    EvaluationUserCapability.where(company_evaluation_template_id: in_self_assessment_evaluation_template_ids,
      user_id: in_self_assessment_user_ids).each do |evaluation_user_capability|
      next unless evaluation_user_capability.form_status == "initial"

      user = evaluation_user_capability.user
      wecom_id = user.wecom_id.present? ? user.wecom_id : user.email.split("@")[0]
      next if wecom_id.blank?

      sent_message = <<~HELLO
        【绩效评价通知】
        2025年年中绩效评价已开始，请尽快登录绩效系统，完成员工自评。
        登录链接：https://performance.thape.com.cn/
      HELLO

      Wechat.api.custom_message_send Wechat::Message.to(wecom_id).text(sent_message)
    rescue Wechat::ResponseError => e
      Rails.logger.error("Failed to send owner need calibrating remind message to wecom_id: #{wecom_id}. Error: #{e.message}")
    end
  end
end
