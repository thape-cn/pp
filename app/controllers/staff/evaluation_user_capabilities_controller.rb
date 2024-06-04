module Staff
  class EvaluationUserCapabilitiesController < BaseController
    after_action :verify_authorized, except: %i[history_expender]
    before_action :set_evaluation_user_capability, only: %i[show update overall_text]

    def show
      @company_evaluation_template = @evaluation_user_capability.company_evaluation_template
      @job_role_performances = JobRoleEvaluationPerformance
        .performance_from_evaluation_user_capability(@evaluation_user_capability)
    end

    def update
      @evaluation_user_capability.assign_attributes(evaluation_user_capability_params)
      if @evaluation_user_capability.form_status_changed?
        @evaluation_user_capability.euc_form_status_histories
          .create(previous_form_status: @evaluation_user_capability.form_status_was,
            form_status: @evaluation_user_capability.form_status, user_id: current_user.id)
      end
      @evaluation_user_capability.save(validate: false)
      head :ok
    end

    def overall_text
      @job_role_performances = JobRoleEvaluationPerformance
        .performance_from_evaluation_user_capability(@evaluation_user_capability)

      @management_capabilities = @evaluation_user_capability.management_capabilities
      @professional_capabilities = @evaluation_user_capability.professional_capabilities

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
        .permit(:manager_overall_output, :manager_overall_improvement, :manager_overall_plan)
    end
  end
end
