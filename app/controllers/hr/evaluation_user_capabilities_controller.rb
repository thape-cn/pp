module HR
  class EvaluationUserCapabilitiesController < BaseController
    after_action :verify_authorized, only: :overall_text
    before_action :set_evaluation_user_capability, only: %i[overall_text]

    def overall_text
      @job_role_performances = JobRoleEvaluationPerformance
        .performance_from_evaluation_user_capability(@evaluation_user_capability)

      @management_capabilities = @evaluation_user_capability.management_capabilities
      @professional_capabilities = @evaluation_user_capability.professional_capabilities

      render layout: false
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
  end
end
