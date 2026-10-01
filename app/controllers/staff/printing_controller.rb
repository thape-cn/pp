module Staff
  class PrintingController < BaseController
    skip_before_action :authenticate_user!, if: -> { request.ip == "::1" || request.ip == "172.17.1.38" }
    skip_before_action :require_user!, if: -> { request.ip == "::1" || request.ip == "172.17.1.38" }
    after_action :verify_authorized

    def show
      printing_pdf = request.ip == "::1" || request.ip == "172.17.1.38"
      if printing_pdf
        sign_in User.where(email: CoreUIsettings.admin.emails).first
      end
      @evaluation_user_capability = authorize(EvaluationUserCapability.find(params[:id]), :print?)
      company_evaluation_template = @evaluation_user_capability.company_evaluation_template

      @job_role_performances = JobRoleEvaluationPerformance
        .performance_from_evaluation_user_capability(@evaluation_user_capability)
      @job_role_performances = @job_role_performances.visible_in_staff_review if printing_pdf || !current_user.admin?

      @performance_capabilities = @evaluation_user_capability.performance_capabilities
      @management_capabilities = @evaluation_user_capability.management_capabilities
      @professional_capabilities = @evaluation_user_capability.professional_capabilities

      @horizontal_position = company_evaluation_template.horizontal_position_for(@evaluation_user_capability)
      @vertical_position = company_evaluation_template.vertical_position_for(@evaluation_user_capability)

      add_to_breadcrumbs company_evaluation_template.title
      set_meta_tags(title: company_evaluation_template.title)
      @_in_print = true
      @_sidebar_name = nil
    end

    def pdf
      evaluation_user_capability = authorize(EvaluationUserCapability.find(params[:id]), :print?)
      enqueue_report_export("staff_printing", options: {
        evaluation_user_capability_id: evaluation_user_capability.id,
        printing_url: staff_printing_url(id: evaluation_user_capability.id, locale: I18n.locale)
      })
    end
  end
end
