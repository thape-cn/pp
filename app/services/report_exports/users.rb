module ReportExports
  class Users < Base
    def call(output_path)
      user_job_roles = policy_scope(UserJobRole).includes(:user, :job_role, :manager_user)
      d2hrbp = HrbpUserManagedDepartment.includes(:user).group_by(&:managed_dept_code)
      p = Axlsx::Package.new
      wb = p.workbook

      wb.add_worksheet(name: "evaluation_progress") do |sheet|
        sheet.add_row [I18n.t("user.user_id"),
          I18n.t("user.email"),
          I18n.t("user.chinese_name"),
          I18n.t("user.clerk_code"),
          I18n.t("user.hire_date"),
          I18n.t("user.user_is_active"),
          I18n.t("user.st_code"),
          I18n.t("user.company"),

          I18n.t("user.department"),
          I18n.t("user.dept_code"),
          I18n.t("user.title"),
          I18n.t("user.user_job_role_is_active"),
          I18n.t("user.job_level"),
          I18n.t("user.job_code"),
          I18n.t("user.job_family"),

          I18n.t("user.manager_user"),
          I18n.t("user.manager_user_clerk_code"),
          I18n.t("user.hrbp_name")]
        user_job_roles.find_each do |ujr|
          values = []
          values << ujr.user.id
          values << ujr.user.email
          values << ujr.user.chinese_name
          values << ujr.user.clerk_code
          values << ujr.user.hire_date
          values << ujr.user.is_active
          values << ujr.job_role.st_code
          values << ujr.company

          values << ujr.department
          values << ujr.dept_code
          values << ujr.title
          values << ujr.is_active
          values << ujr.job_role.job_level
          values << ujr.job_role.job_code
          values << ujr.job_role.job_family

          values << ujr.manager_user&.chinese_name
          values << ujr.manager_user&.clerk_code
          values << d2hrbp[ujr.dept_code]&.collect do |hrbp_user_managed_department|
            hrbp_user_managed_department.user.chinese_name
          end&.join(", ")
          row = sheet.add_row values
          row.cells[3].type = :string
          row.cells[3].value = ujr.user.clerk_code # Must overwrite again after setting cell type
          row.cells[6].type = :string
          row.cells[6].value = ujr.job_role.st_code
          row.cells[9].type = :string
          row.cells[9].value = ujr.dept_code
          row.cells[16].type = :string
          row.cells[16].value = ujr.manager_user&.clerk_code
        end
      end

      p.serialize(output_path)
      "all_pp_users.xlsx"
    end
  end
end
