module HR
  class BaseController < ::ApplicationController
    before_action :require_hr_staff!

    protected

    def require_hr_staff!
      unless user_signed_in? && current_user.hr_staff?
        redirect_back fallback_location: root_url
      end
    end
  end
end
