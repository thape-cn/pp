module Staff
  class InEvaluationController < BaseController
    include SetSidebarEvaluationUserCapability

    before_action :set_sidebar_evaluation_user_capabilities, only: %i[show]
    after_action :verify_authorized

    def show
      @evaluation_user_capability = authorize policy_scope(EvaluationUserCapability).find(params[:id])
      company_evaluation_template = @evaluation_user_capability.company_evaluation_template

      @job_role_performances = JobRoleEvaluationPerformance
        .performance_from_evaluation_user_capability(@evaluation_user_capability)

      @performance_capabilities = @evaluation_user_capability.performance_capabilities
      @management_capabilities = @evaluation_user_capability.management_capabilities
      @professional_capabilities = @evaluation_user_capability.professional_capabilities

      add_to_breadcrumbs company_evaluation_template.title
      set_meta_tags(title: company_evaluation_template.title)
    end
  end
end
