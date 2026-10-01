module ReportExports
  class JobRoles < Base
    def call(output_path)
      job_roles = policy_scope(JobRole).includes(:evaluation_role)
      p = Axlsx::Package.new
      wb = p.workbook

      wb.add_worksheet(name: "job_roles") do |sheet|
        sheet.add_row ["ID",
          I18n.t("user.st_code"),
          I18n.t("user.job_level"),
          I18n.t("user.job_code"),
          I18n.t("user.job_family"),

          I18n.t("form.created_at"),
          I18n.t("form.updated_at"),
          I18n.t("capability.evaluation_roles")]
        job_roles.find_each do |jr|
          values = []
          values << jr.id
          values << jr.st_code
          values << jr.job_level
          values << jr.job_code
          values << jr.job_family

          values << jr.created_at.to_fs(:db_short)
          values << jr.updated_at.to_fs(:db_short)
          values << jr.evaluation_role&.role_name
          row = sheet.add_row values
          row.cells[1].type = :string
          row.cells[1].value = jr.st_code
        end
      end

      p.serialize(output_path)
      "all_job_roles.xlsx"
    end
  end
end
