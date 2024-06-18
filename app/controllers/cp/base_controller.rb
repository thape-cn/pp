module CP
  class BaseController < ::ApplicationController
    before_action :require_corp_president!

    protected

    def require_corp_president!
      unless user_signed_in? && current_user.corp_president?
        redirect_back fallback_location: root_url
      end
    end
  end
end
