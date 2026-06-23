module Staff
  class UserJobRolePerformancesController < BaseController
    def show
      if params[:id] == "undefined"
        render json: {obj_name: "", obj_metric: "", close: I18n.t("form.close")}
      else
        @user_job_role_performance = JobRoleEvaluationPerformance.find(params[:id])
        return head :not_found if @user_job_role_performance.hidden_in_staff_review_for?(current_user)

        authorize @user_job_role_performance
      end
    end
  end
end
