class ConfirmEvaluationUserCapabilityMailer < ApplicationMailer
  def notification_email
    @evaluation_user_capability = params[:evaluation_user_capability]
    mail(to: get_user_email(@evaluation_user_capability.user), subject: "【绩效评价通知】请登录系统确认您的绩效等级")
  end
end
