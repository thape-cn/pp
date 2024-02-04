module Admin
  class UserCapabilitiesController < BaseController
    include MatricHelper
    include Pagy::Backend
    after_action :verify_authorized, except: %i[index excel_report excel_detail_report]
    after_action :verify_policy_scoped, only: %i[index excel_report excel_detail_report]
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
      @pagy, @evaluation_user_capabilities = pagy(evaluation_user_capabilities, items: current_user.preferred_page_length)
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
        manager_scored_total_evaluation_score: @evaluation_user_capability.pre_total_evaluation_score,
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
      company_evaluation = CompanyEvaluation.find params[:company_evaluation_id]
      evaluation_user_capabilities = policy_scope(EvaluationUserCapability)
        .joins(:company_evaluation_template)
        .includes(:user, :job_role, :manager_user)
        .where(company_evaluation_template: {company_evaluation_id: company_evaluation.id})
      respond_to do |format|
        format.xlsx do
          p = Axlsx::Package.new
          wb = p.workbook

          wb.add_worksheet(name: company_evaluation.title) do |sheet|
            sheet.add_row [I18n.t("user.chinese_name"),
              I18n.t("user.user_id"),
              I18n.t("user.clerk_code"),
              I18n.t("user.st_code"),
              I18n.t("evaluation.evaluation_status"),
              I18n.t("user.company"),
              I18n.t("user.department"),

              I18n.t("user.dept_code"),
              I18n.t("admin.evaluation_templates.index.template_title"),
              I18n.t("user.manager_user"),
              I18n.t("user.user_id"),
              I18n.t("evaluation.manager_scored_total_evaluation_score"),
              I18n.t("evaluation.final_total_evaluation_score"),
              I18n.t("evaluation.total_evaluation_score")]
            evaluation_user_capabilities.find_each do |euc|
              values = []
              values << euc.user.chinese_name
              values << euc.user_id
              values << euc.user.clerk_code
              values << euc.job_role.st_code
              values << EvaluationUserCapability.form_status_options.invert[euc.form_status]
              values << euc.company
              values << euc.department

              values << euc.dept_code
              values << euc.company_evaluation_template.title
              values << euc.manager_user&.chinese_name
              values << euc.manager_user_id
              values << public_send(euc.company_evaluation_template.total_reverse_matric, euc.manager_scored_total_evaluation_score)
              values << public_send(euc.company_evaluation_template.total_reverse_matric, euc.final_total_evaluation_score)
              values << public_send(euc.company_evaluation_template.total_reverse_matric, euc.total_evaluation_score)

              row = sheet.add_row values
              row.cells[2].type = :string
              row.cells[2].value = euc.user.clerk_code # Must overwrite again after setting cell type
              row.cells[3].type = :string
              row.cells[3].value = euc.job_role.st_code
              row.cells[7].type = :string
              row.cells[7].value = euc.dept_code
            end
          end

          temp_file = Tempfile.new("admin_excel_report")
          p.serialize temp_file
          send_file temp_file, filename: "#{company_evaluation.title}.xlsx"
        end
      end
    end

    def excel_detail_report
      company_evaluation = CompanyEvaluation.find params[:company_evaluation_id]
      evaluation_user_capabilities = policy_scope(EvaluationUserCapability)
        .joins(:company_evaluation_template)
        .includes(:user, :job_role, :manager_user)
        .where(company_evaluation_template: {company_evaluation_id: company_evaluation.id})
      respond_to do |format|
        format.xlsx do
          p = Axlsx::Package.new
          wb = p.workbook

          wb.add_worksheet(name: company_evaluation.title) do |sheet|
            sheet.add_row [I18n.t("user.chinese_name"),
              I18n.t("user.user_id"),
              I18n.t("user.clerk_code"),
              I18n.t("user.st_code"),
              I18n.t("evaluation.evaluation_status"),
              I18n.t("user.company"),
              I18n.t("user.department"),

              I18n.t("user.dept_code"),
              I18n.t("admin.evaluation_templates.index.template_title"),
              I18n.t("user.manager_user"),
              I18n.t("user.user_id"),
              I18n.t("evaluation.manager_scored_total_evaluation_score"),
              I18n.t("evaluation.final_total_evaluation_score"),
              I18n.t("evaluation.total_evaluation_score"),
              I18n.t("evaluation.evaluation_label"),
              I18n.t("evaluation.evaluation_value")]
            evaluation_user_capabilities.find_each do |euc|
              add_row_to_sheet(sheet, euc, I18n.t("evaluation.self_overall_output"), euc.self_overall_output)
              add_row_to_sheet(sheet, euc, I18n.t("evaluation.self_overall_improvement"), euc.self_overall_improvement)
              add_row_to_sheet(sheet, euc, I18n.t("evaluation.self_overall_plan"), euc.self_overall_plan)
              add_row_to_sheet(sheet, euc, I18n.t("evaluation.manager_overall_output"), euc.manager_overall_output)
              add_row_to_sheet(sheet, euc, I18n.t("evaluation.manager_overall_improvement"), euc.manager_overall_improvement)
              add_row_to_sheet(sheet, euc, I18n.t("evaluation.manager_overall_plan"), euc.manager_overall_plan)
              Capability.performance_column_names.each do |column_name|
                next if euc.attributes[column_name].blank?
                add_row_to_sheet(sheet, euc, I18n.t("evaluation.#{column_name}_pct"), euc.attributes[column_name])
              end
              Capability.profession_column_label_and_names.each do |cp|
                next if euc.attributes[cp.second].blank?
                add_row_to_sheet(sheet, euc, cp.first, euc.attributes[cp.second])
              end
              Capability.management_column_label_and_names.each do |cp|
                next if euc.attributes[cp.second].blank?
                add_row_to_sheet(sheet, euc, cp.first, euc.attributes[cp.second])
              end
              Capability.calibration_column_names.each do |column_name|
                next if euc.attributes[column_name].blank?
                add_row_to_sheet(sheet, euc, I18n.t("calibration.#{column_name}"), euc.attributes[column_name])
              end
            end
          end

          temp_file = Tempfile.new("admin_excel_detail_report")
          p.serialize temp_file
          send_file temp_file, filename: "#{company_evaluation.title}_detail.xlsx"
        end
      end
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
         link: root_path},
        {text: t("layouts.sidebars.admin.user_capabilities"),
         link: nil}
      ]
    end

    def add_row_to_sheet(sheet, euc, label, value)
      values = []
      values << euc.user.chinese_name
      values << euc.user_id
      values << euc.user.clerk_code
      values << euc.job_role.st_code
      values << EvaluationUserCapability.form_status_options.invert[euc.form_status]
      values << euc.company
      values << euc.department

      values << euc.dept_code
      values << euc.company_evaluation_template.title
      values << euc.manager_user&.chinese_name
      values << euc.manager_user_id
      values << public_send(euc.company_evaluation_template.total_reverse_matric, euc.manager_scored_total_evaluation_score)
      values << public_send(euc.company_evaluation_template.total_reverse_matric, euc.final_total_evaluation_score)
      values << public_send(euc.company_evaluation_template.total_reverse_matric, euc.total_evaluation_score)

      row = sheet.add_row values + [label, value]
      row.cells[2].type = :string
      row.cells[2].value = euc.user.clerk_code # Must overwrite again after setting cell type
      row.cells[3].type = :string
      row.cells[3].value = euc.job_role.st_code
      row.cells[7].type = :string
      row.cells[7].value = euc.dept_code
    end
  end
end
