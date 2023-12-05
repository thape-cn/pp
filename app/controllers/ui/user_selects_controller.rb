module UI
  class UserSelectsController < BaseController
    def show
      q = User.sanitize_sql_like(params[:q])
      user_scope = policy_scope(User)
      @users = if current_user.admin? || current_user.hr_staff?
        user_scope.or(User.where(is_active: false, user_job_roles: {company: nil}))
      elsif current_user.hr_bp?
        user_scope.or(User.where(is_active: false, user_job_roles: {dept_code: nil}))
      else
        user_scope
      end.where("chinese_name LIKE ? OR clerk_code LIKE ?", "%#{q}%", "%#{q}%").limit(7)
    end
  end
end
