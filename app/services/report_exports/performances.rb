module ReportExports
  class Performances < Base
    def call(output_path)
      job_role_evaluation_performances = policy_scope(JobRoleEvaluationPerformance)
        .includes(:user, :evaluation_user_capability)
        .where(company_evaluation_id: company_evaluation.id)
      company_by_dept_code = UserJobRole.distinct.pluck(:dept_code, :company).to_h
      department_by_dept_code = UserJobRole.distinct.pluck(:dept_code, :department).to_h
      p = Axlsx::Package.new
      wb = p.workbook

      wb.add_worksheet(name: company_evaluation.title) do |sheet|
        sheet.add_row [I18n.t("user.chinese_name"),
          I18n.t("user.user_id"),
          I18n.t("user.clerk_code"),
          I18n.t("user.st_code"),
          I18n.t("user.company"),
          I18n.t("user.department"),
          I18n.t("user.dept_code"),

          I18n.t("evaluation.import_guid"),
          I18n.t("evaluation.obj_name"),
          I18n.t("evaluation.obj_weight_pct"),
          I18n.t("evaluation.obj_result"),
          I18n.t("evaluation.obj_result_explain"),
          I18n.t("capability.en_name"),
          I18n.t("evaluation.obj_metric"),
          I18n.t("evaluation.obj_result_fixed")]
        job_role_evaluation_performances.find_each do |jrep|
          values = []
          values << jrep.user.chinese_name
          values << jrep.user_id
          values << jrep.user.clerk_code
          values << jrep.st_code
          values << company_by_dept_code[jrep.dept_code]
          values << department_by_dept_code[jrep.dept_code]
          values << jrep.dept_code

          values << jrep.import_guid
          values << jrep.obj_name
          values << jrep.obj_weight_pct
          values << jrep.obj_result
          values << jrep.obj_result_explain
          values << jrep.en_name
          values << jrep.obj_metric
          values << (jrep.obj_result_fixed? ? "Y" : "N")
          row = sheet.add_row values
          row.cells[2].type = :string
          row.cells[2].value = jrep.user.clerk_code # Must overwrite again after setting cell type
          row.cells[3].type = :string
          row.cells[3].value = jrep.st_code
          row.cells[6].type = :string
          row.cells[6].value = jrep.dept_code
          row.cells[7].type = :string
          row.cells[7].value = jrep.import_guid
        end
      end

      p.serialize(output_path)
      "#{company_evaluation.title}.xlsx"
    end
  end
end
