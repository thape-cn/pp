module Admin
  class UserCapabilitiesController < BaseController
    include MetricHelper
    include Pagy::Method
    include ExcelDetailReport

    after_action :verify_authorized, except: %i[index excel_report excel_detail_report]
    after_action :verify_policy_scoped, only: %i[index excel_report]
    before_action :set_company_evaluation, only: %i[new create edit update show
      excel_report excel_detail_report
      sent_self_assessment_confirm sent_self_assessment_remind
      sent_hr_review_completed_confirm sent_hr_review_completed_remind
      custom_description_dialog custom_description]
    before_action :set_evaluation_user_capability, only: %i[edit update show custom_description_dialog custom_description]
    before_action :set_breadcrumbs, if: -> { request.format.html? }

    def index
      @company_evaluation = CompanyEvaluation.find params[:company_evaluation_id]
      title = t(".breadcrumb_title", title: @company_evaluation.title)
      @user_id = params[:user_id]
      @manager_user_id = params[:manager_user_id]
      @company = params[:company]
      @department = params[:department]
      @form_status = params[:form_status]
      @group_level = params[:group_level]
      @sort_on_final_total_evaluation_score = params[:sort_on_final_total_evaluation_score] == "true"
      @show_user_inactive_only = params[:show_user_inactive_only] == "true"
      add_to_breadcrumbs title, admin_company_evaluation_user_capabilities_path(company_evaluation_id: @company_evaluation.id)
      set_meta_tags(title: title)
      evaluation_user_capabilities = policy_scope(EvaluationUserCapability)
        .joins(:company_evaluation_template)
        .includes(:user, :job_role, :manager_user)
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
      if @group_level.present?
        evaluation_user_capabilities = evaluation_user_capabilities.where(company_evaluation_template: {group_level: @group_level})
      end
      evaluation_user_capabilities = evaluation_user_capabilities.order(final_total_evaluation_score: :asc) if @sort_on_final_total_evaluation_score
      evaluation_user_capabilities = evaluation_user_capabilities.where(user: {is_active: false}) if @show_user_inactive_only
      @pagy, @evaluation_user_capabilities = pagy(:offset, evaluation_user_capabilities, limit: current_user.preferred_page_length)
    end

    def show
      render layout: false
    end

    def edit
      render layout: false
    end

    def update
      @evaluation_user_capability.assign_attributes(evaluation_user_capability_params)
      if @evaluation_user_capability.form_status_changed?
        @evaluation_user_capability.euc_form_status_histories
          .create(previous_form_status: @evaluation_user_capability.form_status_was,
            form_status: @evaluation_user_capability.form_status, user_id: current_user.id)
      end
      if @evaluation_user_capability.job_role_id_changed?
        @evaluation_user_capability.initial_capability_score_filling
      end
      @evaluation_user_capability.save(validate: false)
      @evaluation_user_capability.update_columns(
        manager_scored_total_evaluation_score: @evaluation_user_capability.raw_total_evaluation_score,
        final_total_evaluation_score: @evaluation_user_capability.total_evaluation_score
      )
      head :no_content
    end

    def new
      authorize EvaluationUserCapability.new
      render layout: false
    end

    def create
      company_evaluation = CompanyEvaluation.find(params[:company_evaluation_id])
      authorize EvaluationUserCapability.new
      import_excel_file = current_user.import_excel_files
        .create(company_evaluation_id: company_evaluation.id,
          title: company_evaluation.title, import_type: "new_evaluation")
      import_excel_file.excel_file.attach(params[:file])
      ImportNewEvaluationJob.perform_async(import_excel_file.id)
    end

    def excel_report
      enqueue_report_export("admin_evaluations")
    end

    def sent_hr_review_completed_confirm
      render layout: false
    end

    def sent_hr_review_completed_remind
      xlsx = Roo::Excelx.new(params[:file])
      xlsx.each(
        clerk_code: "USERNAME"
      ) do |h|
        clerk_code = h[:clerk_code].to_s
        next if clerk_code == "USERNAME"
        next if clerk_code.blank?

        if params[:send_email] == "true"
          StaffNeedConfirmRemindEmailJob.perform_async(@company_evaluation.id, clerk_code)
        end
        if params[:send_wecom_message] == "true"
          StaffNeedConfirmRemindWecomJob.perform_async(@company_evaluation.id, clerk_code)
        end
      end
    end

    def sent_self_assessment_confirm
      render layout: false
    end

    def sent_self_assessment_remind
      xlsx = Roo::Excelx.new(params[:file])
      xlsx.each(
        clerk_code: "USERNAME"
      ) do |h|
        clerk_code = h[:clerk_code].to_s
        next if clerk_code == "USERNAME"
        next if clerk_code.blank?

        if params[:send_email] == "true"
          SentSelfAssessmentRemindEmailJob.perform_async(@company_evaluation.id, clerk_code)
        end
        if params[:send_wecom_message] == "true"
          SentSelfAssessmentRemindWecomJob.perform_async(@company_evaluation.id, clerk_code)
        end
      end
    end

    def custom_description_dialog
      render layout: false
    end

    def custom_description
      EvaluationUserCapabilityDescription.create(
        company_evaluation_template_id: params[:company_evaluation_template_id],
        user_id: params[:user_id],
        capability_id: params[:capability_id],
        description: params[:description]
      )
    end

    private

    def set_company_evaluation
      @company_evaluation = authorize CompanyEvaluation.find params[:company_evaluation_id]
    end

    def set_evaluation_user_capability
      @evaluation_user_capability = authorize policy_scope(EvaluationUserCapability)
        .joins(:company_evaluation_template)
        .where(company_evaluation_template: {company_evaluation_id: @company_evaluation.id})
        .find(params[:id])
    end

    def evaluation_user_capability_params
      params.require(:evaluation_user_capability)
        .permit(:form_status, :job_role_id, :manager_user_id,
          :manager_overall_output, :manager_overall_improvement, :manager_overall_plan,
          *Capability.performance_column_names,
          *Capability.profession_column_names,
          *Capability.management_column_names,
          *Capability.calibration_column_names)
    end

    def set_breadcrumbs
      @_breadcrumbs = [
        {text: t("layouts.sidebars.admin.header"),
         link: admin_root_path},
        {text: t("layouts.sidebars.admin.user_capabilities"),
         link: nil}
      ]
    end
  end
end
