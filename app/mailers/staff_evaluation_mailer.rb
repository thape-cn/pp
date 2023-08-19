class StaffEvaluationMailer < ApplicationMailer
  def start
    @evaluation_user_capability = params[:evaluation_user_capability]
    @user = @evaluation_user_capability.user

    mail to: get_user_email(@user), subject: "【绩效评价】您的绩效评价沟通表等待填写"
  end
end
