module CP
  class UserCapabilitiesController < BaseController
    include MetricHelper
    include Pagy::Backend
    after_action :verify_policy_scoped, only: %i[index excel_report]
    before_action :set_breadcrumbs, if: -> { request.format.html? }

    def index
      @company_evaluation = CompanyEvaluation.find params[:company_evaluation_id]
      title = t(".breadcrumb_title", title: @company_evaluation.title)
      @user_id = params[:user_id]
      @manager_user_id = params[:manager_user_id]
      @department = params[:department]
      @form_status = params[:form_status]
      @sort_on_final_total_evaluation_score = params[:sort_on_final_total_evaluation_score] == "true"
      add_to_breadcrumbs title, cp_company_evaluation_user_capabilities_path(company_evaluation_id: @company_evaluation)
      set_meta_tags(title: title)
      evaluation_user_capabilities = policy_scope(EvaluationUserCapability)
        .joins(:company_evaluation_template)
        .includes(:user, :job_role, :manager_user)
        .where(company_evaluation_template: {company_evaluation_id: @company_evaluation.id})
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
      if @department.present?
        evaluation_user_capabilities = evaluation_user_capabilities.where(department: @department)
      end
      evaluation_user_capabilities = evaluation_user_capabilities.where(form_status: @form_status) if @form_status.present?
      evaluation_user_capabilities = evaluation_user_capabilities.order(final_total_evaluation_score: :asc) if @sort_on_final_total_evaluation_score.present?
      @pagy, @evaluation_user_capabilities = pagy(evaluation_user_capabilities, items: current_user.preferred_page_length)
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
              I18n.t("user.clerk_code"),
              I18n.t("user.st_code"),
              I18n.t("evaluation.evaluation_status"),
              I18n.t("user.company"),
              I18n.t("user.department"),
              I18n.t("user.title"),

              I18n.t("user.dept_code"),
              I18n.t("admin.evaluation_templates.index.template_title"),
              I18n.t("user.manager_user"),
              I18n.t("evaluation.final_total_evaluation_score")]
            evaluation_user_capabilities.find_each do |euc|
              values = []
              values << euc.user.chinese_name
              values << euc.user.clerk_code
              values << euc.job_role.st_code
              values << EvaluationUserCapability.form_status_options.invert[euc.form_status]
              values << euc.company
              values << euc.department
              values << euc.title

              values << euc.dept_code
              values << euc.company_evaluation_template.title
              values << euc.manager_user&.chinese_name
              values << reverse_5_metric(euc.final_total_evaluation_score)
              row = sheet.add_row values
              row.cells[1].type = :string
              row.cells[1].value = euc.user.clerk_code # Must overwrite again after setting cell type
              row.cells[2].type = :string
              row.cells[2].value = euc.job_role.st_code
              row.cells[7].type = :string
              row.cells[7].value = euc.dept_code
            end
          end

          temp_file = Tempfile.new("hf_excel_report")
          p.serialize temp_file
          send_file temp_file, filename: "#{company_evaluation.title}.xlsx"
        end
      end
    end

    private

    def set_breadcrumbs
      @_breadcrumbs = [
        {text: t("layouts.sidebars.corp_president.header"),
         link: cp_root_path},
        {text: t("layouts.sidebars.corp_president.user_capabilities"),
         link: nil}
      ]
    end
  end
end
