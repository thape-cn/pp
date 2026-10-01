module ReportExports
  class AdminEvaluationDetails < Base
    def call(output_path)
      evaluation_user_capabilities = policy_scope(EvaluationUserCapability)
        .joins(:company_evaluation_template)
        .includes(:user, :job_role, :manager_user, :company_evaluation_template)
        .where(company_evaluation_template: {company_evaluation_id: company_evaluation.id})
      detail_labels = capability_detail_labels
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
        each_with_performance_scores(evaluation_user_capabilities) do |euc, scores|
          values = evaluation_values(euc, scores.fetch(euc.id, 0))
          add_row_to_sheet(sheet, values, I18n.t("evaluation.self_overall_output"), euc.self_overall_output)
          add_row_to_sheet(sheet, values, I18n.t("evaluation.self_overall_improvement"), euc.self_overall_improvement)
          add_row_to_sheet(sheet, values, I18n.t("evaluation.self_overall_plan"), euc.self_overall_plan)
          add_row_to_sheet(sheet, values, I18n.t("evaluation.manager_overall_output"), euc.manager_overall_output)
          add_row_to_sheet(sheet, values, I18n.t("evaluation.manager_overall_improvement"), euc.manager_overall_improvement)
          add_row_to_sheet(sheet, values, I18n.t("evaluation.manager_overall_plan"), euc.manager_overall_plan)
          detail_labels.each do |column_name, label|
            value = euc.read_attribute(column_name)
            next if value.blank?

            add_row_to_sheet(sheet, values, label, value)
          end
        end
      end

      p.serialize(output_path)
      "#{company_evaluation.title}_detail.xlsx"
    end

    private

    def evaluation_values(euc, uploaded_performance_result)
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
      values << euc.total_score_in_metric(uploaded_performance_result: uploaded_performance_result)

      values
    end

    def add_row_to_sheet(sheet, values, label, value)
      row = sheet.add_row values + [label, value]
      row.cells[2].type = :string
      row.cells[2].value = values[2]
      row.cells[3].type = :string
      row.cells[3].value = values[3]
      row.cells[7].type = :string
      row.cells[7].value = values[7]
    end
  end
end
