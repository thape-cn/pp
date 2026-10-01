module ReportExports
  class AdminEvaluations < Base
    def call(output_path)
      evaluation_user_capabilities = policy_scope(EvaluationUserCapability)
        .joins(:company_evaluation_template)
        .includes(:user, :job_role, :manager_user, :company_evaluation_template)
        .where(company_evaluation_template: {company_evaluation_id: company_evaluation.id})
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
          values << euc.manager_scored_in_metric
          values << euc.final_score_in_metric
          values << euc.total_score_in_metric

          row = sheet.add_row values
          row.cells[2].type = :string
          row.cells[2].value = euc.user.clerk_code # Must overwrite again after setting cell type
          row.cells[3].type = :string
          row.cells[3].value = euc.job_role.st_code
          row.cells[7].type = :string
          row.cells[7].value = euc.dept_code
        end
      end

      p.serialize(output_path)
      "#{company_evaluation.title}.xlsx"
    end
  end
end
