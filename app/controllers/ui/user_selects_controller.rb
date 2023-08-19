module UI
  class UserSelectsController < BaseController
    def show
      q = User.sanitize_sql_like(params[:q])
      @users = policy_scope(User).where("chinese_name LIKE ? OR clerk_code LIKE ?", "%#{q}%", "%#{q}%").limit(7)
    end
  end
end
