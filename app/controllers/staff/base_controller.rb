module Staff
  class BaseController < ::ApplicationController
    before_action :require_user!

    protected

    def require_user!
      unless user_signed_in?
        redirect_back fallback_location: root_url
      end
    end
  end
end
