module Staff
  class SigningController < BaseController
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

      @horizontal_position = case company_evaluation_template.group_level
      when "staff"
        @evaluation_user_capability.group_of_staff_work_quality_and_work_attitude
      when "auxiliary"
        @evaluation_user_capability.group_of_manager_management_profession
      when "manager_a"
        @evaluation_user_capability.group_of_manager_management_profession
      when "manager_a"
        @evaluation_user_capability.group_of_manager_only_management
      end

      @vertical_position = case company_evaluation_template.group_level
      when "staff"
        @evaluation_user_capability.group_of_staff_work_load
      when "auxiliary"
        @evaluation_user_capability.group_of_manager_performance
      when "manager_a"
        @evaluation_user_capability.group_of_manager_performance
      when "manager_a"
        @evaluation_user_capability.group_of_manager_only_profession
      end

      @evaluation_user_capability.sign_date ||= Date.today
      add_to_breadcrumbs company_evaluation_template.title
      set_meta_tags(title: company_evaluation_template.title)
    end

    def update
      @evaluation_user_capability = authorize policy_scope(EvaluationUserCapability).find(params[:id])

      @evaluation_user_capability.update(sign_date: Date.today)

      @evaluation_user_capability.update_form_status_to("data_locked", current_user)
      redirect_to staff_root_path, notice: t(".update_success", id: @evaluation_user_capability.id)
    end
  end
end
