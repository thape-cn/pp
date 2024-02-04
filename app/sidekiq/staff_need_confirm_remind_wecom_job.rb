class StaffNeedConfirmRemindWecomJob
  include Sidekiq::Job

  def perform(company_evaluation_id, clerk_code)
    need_confirm_evaluation_template_ids = CompanyEvaluationTemplate
      .where(company_evaluation_id: company_evaluation_id).pluck(:id)
    need_confirm_user_ids = User.where(clerk_code: clerk_code, is_active: true).pluck(:id)

    EvaluationUserCapability.where(company_evaluation_template_id: need_confirm_evaluation_template_ids,
      user_id: need_confirm_user_ids).each do |evaluation_user_capability|
      next unless evaluation_user_capability.form_status == "hr_review_completed"

      user = evaluation_user_capability.user
      wecom_id = user.wecom_id.present? ? user.wecom_id : user.email.split("@")[0]
      next if wecom_id.blank?

      sent_message = <<~HELLO
        【绩效评价通知】
        请尽快登录绩效系统，确认并查看绩效评价结果
        登录链接：https://performance.thape.com.cn/staff/signing/#{evaluation_user_capability.id}
      HELLO

      Wechat.api.custom_message_send Wechat::Message.to(wecom_id).text(sent_message)
    rescue Wechat::ResponseError => e
      Rails.logger.error("Failed to send staff need confirm remind message to wecom_id: #{wecom_id}. Error: #{e.message}")
    end
  end
end
