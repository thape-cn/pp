module Staff
  class PrintingController < BaseController
    skip_before_action :authenticate_user!, if: -> { request.ip == "::1" || request.ip == "172.17.1.38" }
    skip_before_action :require_user!, if: -> { request.ip == "::1" || request.ip == "172.17.1.38" }
    after_action :verify_authorized

    def show
      if request.ip == "::1" || request.ip == "172.17.1.38"
        sign_in User.where(email: CoreUIsettings.admin.emails).first
      end
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

    def pdf
      evaluation_user_capability = authorize(EvaluationUserCapability.find(params[:id]), :print?)
      browser = Ferrum::Browser.new
      browser.go_to staff_printing_url(id: evaluation_user_capability.id)
      browser.network.wait_for_idle

      temp_file = Tempfile.new(["printed", ".pdf"])
      browser.pdf(path: temp_file.path)

      pdf_data = File.read(temp_file.path)
      send_data(pdf_data, filename: "#{params[:id]}_printed.pdf", type: "application/pdf", disposition: "inline")

      temp_file.close
      temp_file.unlink
    end
  end
end
