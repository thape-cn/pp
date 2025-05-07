module Staff
  class UserCapabilitiesController < BaseController
    include MetricHelper
    include Pagy::Backend
    include SetSidebarEvaluationUserCapability
    before_action :set_sidebar_evaluation_user_capabilities, only: %i[index]
    after_action :verify_policy_scoped, only: %i[index excel_report excel_detail_report]

    def index
      @company_evaluation = CompanyEvaluation.find params[:company_evaluation_id]
      @user_id = params[:user_id]
      @manager_user_id = params[:manager_user_id]
      @form_status = params[:form_status]
      @sort_on_final_total_evaluation_score = params[:sort_on_final_total_evaluation_score] == "true"
      evaluation_user_capabilities = policy_scope(EvaluationUserCapability)
        .joins(:company_evaluation_template)
        .includes(:user, :job_role, :manager_user)
        .where(company_evaluation_template: {company_evaluation_id: @company_evaluation.id})
      if @user_id.present?
        evaluation_user_capabilities = evaluation_user_capabilities.where(user_id: @user_id)
      end
      if @manager_user_id.present?
        evaluation_user_capabilities = evaluation_user_capabilities.where(manager_user_id: @manager_user_id)
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
              I18n.t("user.company"),
              I18n.t("user.department"),

              I18n.t("admin.evaluation_templates.index.template_title"),
              I18n.t("user.manager_user"),
              I18n.t("evaluation.evaluation_status"),
              I18n.t("evaluation.final_total_evaluation_score")]
            evaluation_user_capabilities.find_each do |euc|
              values = []
              values << euc.user.chinese_name
              values << euc.user.clerk_code
              values << euc.company
              values << euc.department

              values << euc.company_evaluation_template.title
              values << euc.manager_user&.chinese_name
              values << EvaluationUserCapability.form_status_options.invert[euc.form_status]
              values << euc.final_score_in_metric
              row = sheet.add_row values
              row.cells[1].type = :string
              row.cells[1].value = euc.user.clerk_code
            end
          end

          temp_file = Tempfile.new("staff_excel_report")
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
              I18n.t("user.clerk_code"),
              I18n.t("user.company"),
              I18n.t("user.department"),

              I18n.t("admin.evaluation_templates.index.template_title"),
              I18n.t("user.manager_user"),
              I18n.t("evaluation.evaluation_status"),
              I18n.t("evaluation.final_total_evaluation_score"),
              I18n.t("evaluation.evaluation_label"),
              I18n.t("evaluation.evaluation_value")]
            evaluation_user_capabilities.find_each do |euc|
              values = []
              values << euc.user.chinese_name
              values << euc.user.clerk_code
              values << euc.company
              values << euc.department

              values << euc.company_evaluation_template.title
              values << euc.manager_user&.chinese_name
              values << EvaluationUserCapability.form_status_options.invert[euc.form_status]
              values << euc.final_score_in_metric
              row = sheet.add_row values + [I18n.t("evaluation.self_overall_output"), euc.self_overall_output]
              row.cells[1].type = :string
              row.cells[1].value = euc.user.clerk_code
              row = sheet.add_row values + [I18n.t("evaluation.self_overall_improvement"), euc.self_overall_improvement]
              row.cells[1].type = :string
              row.cells[1].value = euc.user.clerk_code
              row = sheet.add_row values + [I18n.t("evaluation.self_overall_plan"), euc.self_overall_plan]
              row.cells[1].type = :string
              row.cells[1].value = euc.user.clerk_code
              row = sheet.add_row values + [I18n.t("evaluation.manager_overall_output"), euc.manager_overall_output]
              row.cells[1].type = :string
              row.cells[1].value = euc.user.clerk_code
              row = sheet.add_row values + [I18n.t("evaluation.manager_overall_improvement"), euc.manager_overall_improvement]
              row.cells[1].type = :string
              row.cells[1].value = euc.user.clerk_code
              row = sheet.add_row values + [I18n.t("evaluation.manager_overall_plan"), euc.manager_overall_plan]
              row.cells[1].type = :string
              row.cells[1].value = euc.user.clerk_code # Must overwrite again after setting cell type
            end
          end

          temp_file = Tempfile.new("staff_excel_detail_report")
          p.serialize temp_file
          send_file temp_file, filename: "#{company_evaluation.title}_detail.xlsx"
        end
      end
    end
  end
end
