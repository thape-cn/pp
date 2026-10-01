module ReportExports
  class Progress < Base
    def call(output_path)
      evaluation_ids = policy_scope(CompanyEvaluation).open_for_user.select(:id)
      evaluation_user_capabilities = policy_scope(EvaluationUserCapability)
        .includes(:company_evaluation_template, :user, :manager_user)
        .where(company_evaluation_template: {company_evaluation_id: evaluation_ids})
      if report_export.report_type == "staff_progress"
        dept_codes = current_user.hrbp_user_managed_departments.pluck(:managed_dept_code)
        dept_codes = current_user.secretary_managed_departments.pluck(:managed_dept_code) if dept_codes.empty?
        evaluation_user_capabilities = evaluation_user_capabilities.where(dept_code: dept_codes)
      end

      p = Axlsx::Package.new
      wb = p.workbook

      wb.add_worksheet(name: "evaluation_progress") do |sheet|
        sheet.add_row [I18n.t("evaluation.evaluation_status"),
          I18n.t("evaluation.template_title"),
          I18n.t("user.clerk_code"),
          I18n.t("user.chinese_name"),
          I18n.t("user.company"),
          I18n.t("user.department"),
          I18n.t("user.manager_user")]
        evaluation_user_capabilities.find_each do |euc|
          values = []
          values << EvaluationUserCapability.form_status_options.invert[euc.form_status]
          values << euc.company_evaluation_template.title
          values << euc.user.clerk_code
          values << euc.user.chinese_name
          values << euc.company
          values << euc.department
          values << euc.manager_user&.chinese_name
          row = sheet.add_row values
          row.cells[2].type = :string
          row.cells[2].value = euc.user.clerk_code # Must overwrite again after setting cell type
        end
      end

      p.serialize(output_path)
      case report_export.report_type
      when "admin_progress" then "admin_evaluation_progress.xlsx"
      when "hr_progress" then "hr_evaluation_progress.xlsx"
      else "evaluation_progress.xlsx"
      end
    end
  end
end
