class ApplicationMailer < ActionMailer::Base
  default from: "performance@thape.com.cn"
  layout "mailer"
  helper :matric

  def get_user_email(user)
    if Rails.env.development?
      "guochunzhong@thape.com.cn"
    else
      user.email
    end
  end
end
