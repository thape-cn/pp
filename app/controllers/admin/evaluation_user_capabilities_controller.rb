module Admin
  class EvaluationUserCapabilitiesController < BaseController
    after_action :verify_authorized, except: %i[expender history_expender]
    before_action :set_evaluation_user_capability, only: %i[overall_text confirm_destroy destroy]

    def create
      p = evaluation_user_capability_params
      ujr = UserJobRole.find_by!(user_id: p[:user_id], job_role_id: p[:job_role_id])
      evaluation_user_capability = authorize EvaluationUserCapability.new(p)
      evaluation_user_capability.manager_user_id = ujr.manager_user_id
      evaluation_user_capability.company = ujr.company
      evaluation_user_capability.department = ujr.department
      evaluation_user_capability.dept_code = ujr.dept_code
      evaluation_user_capability.title = ujr.title
      evaluation_user_capability.save
      evaluation_user_capability.initial_capability_score_filling
    end

    def overall_text
      @job_role_performances = JobRoleEvaluationPerformance
        .performance_from_evaluation_user_capability(@evaluation_user_capability)

      @management_capabilities = @evaluation_user_capability.management_capabilities
      @professional_capabilities = @evaluation_user_capability.professional_capabilities

      render layout: false
    end

    def confirm_destroy
      render layout: false
    end

    def destroy
      @evaluation_user_capability.deleted_user_id = current_user.id
      @evaluation_user_capability.deleted_reason = evaluation_user_capability_params[:deleted_reason]
      @evaluation_user_capability.destroy
    end

    def expender
      render layout: false
    end

    def history_expender
      render layout: false
    end

    private

    def set_evaluation_user_capability
      @evaluation_user_capability = authorize policy_scope(EvaluationUserCapability).find(params[:id])
    end

    def evaluation_user_capability_params
      params.require(:evaluation_user_capability)
        .permit(:user_id, :company_evaluation_template_id, :job_role_id, :deleted_reason)
    end
  end
end
