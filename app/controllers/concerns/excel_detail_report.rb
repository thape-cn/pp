module ExcelDetailReport
  extend ActiveSupport::Concern
  included do
    after_action :verify_policy_scoped, only: %i[excel_detail_report]
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

  private

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
    values << euc.manager_scored_in_metric
    values << euc.final_score_in_metric
    values << euc.total_score_in_metric

    row = sheet.add_row values + [label, value]
    row.cells[2].type = :string
    row.cells[2].value = euc.user.clerk_code # Must overwrite again after setting cell type
    row.cells[3].type = :string
    row.cells[3].value = euc.job_role.st_code
    row.cells[7].type = :string
    row.cells[7].value = euc.dept_code
  end
end
