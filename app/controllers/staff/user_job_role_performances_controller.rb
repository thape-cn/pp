module Staff
  class UserJobRolePerformancesController < BaseController
    def show
      if params[:id] == "undefined"
        render json: {obj_name: "", obj_metric: "", close: I18n.t("form.close")}
      else
        @user_job_role_performance = authorize JobRoleEvaluationPerformance.find(params[:id])
      end
    end
  end
end
