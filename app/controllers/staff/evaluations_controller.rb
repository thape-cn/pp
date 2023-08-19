module Staff
  class EvaluationsController < BaseController
    include SetSidebarEvaluationUserCapability
    before_action :set_sidebar_evaluation_user_capabilities, only: %i[show expender]
    before_action :set_breadcrumbs, if: -> { request.format.html? }
    after_action :verify_authorized, except: %i[expender]

    def show
      @evaluation_user_capability = authorize policy_scope(EvaluationUserCapability).find(params[:id])
      return redirect_to staff_in_evaluation_path(id: @evaluation_user_capability.id), alert: I18n.t("evaluation.form_submitted") unless @evaluation_user_capability.form_status == "initial"

      title = @evaluation_user_capability.company_evaluation_template.title

      @job_role_performances = JobRoleEvaluationPerformance
        .performance_from_evaluation_user_capability(@evaluation_user_capability)

      @performance_capabilities = @evaluation_user_capability.performance_capabilities
      @management_capabilities = @evaluation_user_capability.management_capabilities
      @professional_capabilities = @evaluation_user_capability.professional_capabilities

      add_to_breadcrumbs title
      set_meta_tags(title: title)
    end

    def update
      @evaluation_user_capability = authorize policy_scope(EvaluationUserCapability).find(params[:id])

      result = case params["commit"]
      when I18n.t("form.save")
        @evaluation_user_capability.assign_attributes(evaluation_user_capability_params)
        @evaluation_user_capability.save(validate: false)
      when I18n.t("form.submit")
        @evaluation_user_capability.update(evaluation_user_capability_params)
      end

      if result
        case params["commit"]
        when I18n.t("form.save")
          redirect_to staff_evaluation_path(id: @evaluation_user_capability.id), notice: t(".update_success", id: @evaluation_user_capability.id)
        when I18n.t("form.submit")
          @evaluation_user_capability.update_form_status_to("self_assessment_done", current_user)
          redirect_to staff_root_path, alert: I18n.t("evaluation.form_submitted")
        end
      else
        @evaluation_user_capability.assign_attributes(evaluation_user_capability_params)
        @evaluation_user_capability.save(validate: false)
        redirect_to staff_evaluation_path(id: @evaluation_user_capability.id), alert: @evaluation_user_capability.errors.full_messages.to_sentence
      end
    end

    def expender
      render layout: false
    end

    private

    def evaluation_user_capability_params
      params.require(:evaluation_user_capability)
        .permit(:self_overall_output, :self_overall_improvement, :self_overall_plan)
    end

    def set_breadcrumbs
      @_breadcrumbs = [
        {text: t("layouts.sidebars.staff.header"),
         link: root_path},
        {text: t("layouts.sidebars.staff.evaluation"),
         link: nil}
      ]
    end
  end
end
