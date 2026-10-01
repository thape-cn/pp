module ReportExports
  class StaffEvaluationDetails < Base
    def call(output_path)
      evaluation_user_capabilities = policy_scope(EvaluationUserCapability)
        .joins(:company_evaluation_template)
        .includes(:user, :job_role, :manager_user, :company_evaluation_template)
        .where(company_evaluation_template: {company_evaluation_id: company_evaluation.id})
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

      p.serialize(output_path)
      "#{company_evaluation.title}_detail.xlsx"
    end
  end
end
