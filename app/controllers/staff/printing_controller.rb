module Staff
  class PrintingController < BaseController
    after_action :verify_authorized

    def show
      @evaluation_user_capability = authorize(EvaluationUserCapability.find(params[:id]), :print?)
      company_evaluation_template = @evaluation_user_capability.company_evaluation_template

      @job_role_performances = JobRoleEvaluationPerformance
        .performance_from_evaluation_user_capability(@evaluation_user_capability)

      @performance_capabilities = @evaluation_user_capability.performance_capabilities
      @management_capabilities = @evaluation_user_capability.management_capabilities
      @professional_capabilities = @evaluation_user_capability.professional_capabilities

      @horizontal_position = case company_evaluation_template.group_level
      when "staff"
        @evaluation_user_capability.group_of_staff_work_quality_and_work_attitude
      when "manager"
        @evaluation_user_capability.group_of_manager_capability
      end

      @vertical_position = case company_evaluation_template.group_level
      when "staff"
        @evaluation_user_capability.group_of_staff_work_load
      when "manager"
        @evaluation_user_capability.group_of_manager_performance
      end

      add_to_breadcrumbs company_evaluation_template.title
      set_meta_tags(title: company_evaluation_template.title)
      @_in_print = true
      @_sidebar_name = nil
    end
  end
end
