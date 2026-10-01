module HR
  class UserCapabilitiesController < BaseController
    include MetricHelper
    include Pagy::Method

    after_action :verify_authorized, except: %i[index excel_report excel_detail_report]
    after_action :verify_policy_scoped, only: %i[index excel_report excel_detail_report]
    before_action :set_evaluation_user_capability, only: %i[edit update]
    before_action :set_breadcrumbs, if: -> { request.format.html? }

    def index
      @company_evaluation = CompanyEvaluation.find params[:company_evaluation_id]
      title = t(".breadcrumb_title", title: @company_evaluation.title)
      @user_id = params[:user_id]
      @manager_user_id = params[:manager_user_id]
      @company = params[:company]
      @department = params[:department]
      @form_status = params[:form_status]
      @sort_on_final_total_evaluation_score = params[:sort_on_final_total_evaluation_score] == "true"
      add_to_breadcrumbs title, hr_company_evaluation_user_capabilities_path(company_evaluation_id: @company_evaluation)
      set_meta_tags(title: title)
      evaluation_user_capabilities = policy_scope(EvaluationUserCapability)
        .joins(:company_evaluation_template)
        .includes(:user, :job_role, :manager_user, :company_evaluation_template)
        .where(company_evaluation_template: {company_evaluation_id: @company_evaluation.id})
      @all_companies = policy_scope(EvaluationUserCapability)
        .joins(:company_evaluation_template)
        .where(company_evaluation_template: {company_evaluation_id: @company_evaluation.id})
        .select(:company).distinct.pluck(:company)
      @all_departments = policy_scope(EvaluationUserCapability)
        .joins(:company_evaluation_template)
        .where(company_evaluation_template: {company_evaluation_id: @company_evaluation.id})
        .select(:department).distinct.pluck(:department)
      if @user_id.present?
        evaluation_user_capabilities = evaluation_user_capabilities.where(user_id: @user_id)
      end
      if @manager_user_id.present?
        evaluation_user_capabilities = evaluation_user_capabilities.where(manager_user_id: @manager_user_id)
      end
      if @company.present?
        evaluation_user_capabilities = evaluation_user_capabilities.where(company: @company)
      end
      if @department.present?
        evaluation_user_capabilities = evaluation_user_capabilities.where(department: @department)
      end
      evaluation_user_capabilities = evaluation_user_capabilities.where(form_status: @form_status) if @form_status.present?
      evaluation_user_capabilities = evaluation_user_capabilities.order(final_total_evaluation_score: :asc) if @sort_on_final_total_evaluation_score.present?
      @pagy, @evaluation_user_capabilities = pagy(:offset, evaluation_user_capabilities, limit: current_user.preferred_page_length)
    end

    def edit
      @calibration_session = policy_scope(CalibrationSession)
        .includes(:calibration_session_users)
        .where(calibration_template_id: CalibrationTemplate.open_for_user_calibration_template_ids)
        .where(calibration_session_users: {evaluation_user_capability_id: @evaluation_user_capability.id})
        .order(id: :desc)
        .first
      render layout: false
    end

    def update
      @evaluation_user_capability.assign_attributes(evaluation_user_capability_params)
      if @evaluation_user_capability.form_status_changed? && @evaluation_user_capability.valid?
        @evaluation_user_capability.euc_form_status_histories
          .create(previous_form_status: @evaluation_user_capability.form_status_was,
            form_status: @evaluation_user_capability.form_status, user_id: current_user.id)
        if @evaluation_user_capability.form_status_was == "self_assessment_done" && @evaluation_user_capability.form_status == "manager_scored"
          @evaluation_user_capability.update_columns(
            manager_scored_total_evaluation_score: @evaluation_user_capability.raw_total_evaluation_score,
            final_total_evaluation_score: @evaluation_user_capability.total_evaluation_score
          )
        elsif @evaluation_user_capability.form_status_was == "manager_scored" && @evaluation_user_capability.form_status == "department_calibrated"
          @evaluation_user_capability.update_columns(final_total_evaluation_score: @evaluation_user_capability.total_evaluation_score)
        end
      end
      @evaluation_user_capability.save
      head :no_content
    end

    def excel_report
      enqueue_report_export("hr_evaluations")
    end

    def excel_detail_report
      enqueue_report_export("hr_evaluation_details")
    end

    private

    def set_evaluation_user_capability
      @company_evaluation = CompanyEvaluation.find params[:company_evaluation_id]
      @evaluation_user_capability = authorize policy_scope(EvaluationUserCapability)
        .joins(:company_evaluation_template)
        .where(company_evaluation_template: {company_evaluation_id: @company_evaluation.id})
        .find(params[:id])
    end

    def evaluation_user_capability_params
      params.require(:evaluation_user_capability).permit(:form_status)
    end

    def set_breadcrumbs
      @_breadcrumbs = [
        {text: t("layouts.sidebars.hr_staff.header"),
         link: hr_root_path},
        {text: t("layouts.sidebars.hr_staff.user_capabilities"),
         link: nil}
      ]
    end
  end
end
