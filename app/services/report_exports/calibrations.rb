module ReportExports
  class Calibrations < Base
    def call(output_path)
      evaluation_user_capability_ids = policy_scope(EvaluationUserCapability)
        .joins(:company_evaluation_template)
        .where(company_evaluation_template: {company_evaluation_id: company_evaluation.id})
        .select(:id)
      calibration_session_users = CalibrationSessionUser
        .includes(:user, evaluation_user_capability: [:user, :job_role, :manager_user, :company_evaluation_template])
        .includes(calibration_session: [:owner, {calibration_session_judges: :judge}, :calibration_template])
        .where(evaluation_user_capability_id: evaluation_user_capability_ids)
        .distinct
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
          I18n.t("calibration.session_name"),
          I18n.t("calibration.owner"),
          I18n.t("user.user_id"),
          I18n.t("calibration.judge"),
          I18n.t("user.user_id"),
          I18n.t("calibration.calibration_template")]
        calibration_session_users.find_each do |csu|
          euc = csu.evaluation_user_capability
          values = []
          values << csu.user.chinese_name
          values << csu.user_id
          values << csu.user.clerk_code
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
          values << csu.calibration_session.session_name
          values << csu.calibration_session.owner.chinese_name
          values << csu.calibration_session.owner_id
          values << csu.calibration_session.calibration_session_judges.collect { |csj| csj.judge.chinese_name }.join(",")
          values << csu.calibration_session.calibration_session_judges.collect { |csj| csj.judge_id }.join(",")
          values << csu.calibration_session.calibration_template.template_name
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
