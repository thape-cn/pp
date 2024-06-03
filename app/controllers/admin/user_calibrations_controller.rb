module Admin
  class UserCalibrationsController < BaseController
    include MatricHelper
    include Pagy::Backend
    after_action :verify_authorized, except: %i[index excel_report]
    after_action :verify_policy_scoped, only: %i[index excel_report]
    before_action :set_breadcrumbs, if: -> { request.format.html? }

    def index
      @company_evaluation = CompanyEvaluation.find params[:company_evaluation_id]
      title = t(".breadcrumb_title", title: @company_evaluation.title)
      add_to_breadcrumbs title
      set_meta_tags(title: title)
      calibration_session_users = policy_scope(CalibrationSessionUser)
        .includes(:user, {calibration_session: {calibration_template: :company_evaluation_template}})
        .where(calibration_session: {calibration_template: {company_evaluation_templates: {company_evaluation_id: @company_evaluation.id}}})
      @user_id = params[:user_id].presence
      calibration_session_users = if @user_id.present?
        calibration_session_users.where(user_id: @user_id)
      else
        calibration_session_users
      end
      @select_no_evaluation_user_capability = params[:select_no_evaluation_user_capability] == "true"
      calibration_session_users = if @select_no_evaluation_user_capability
        calibration_session_users.left_outer_joins(:evaluation_user_capability).where(evaluation_user_capability: {id: nil})
      else
        calibration_session_users
      end
      @pagy, @calibration_session_users = pagy(calibration_session_users, items: current_user.preferred_page_length)
    end

    def excel_report
      company_evaluation = CompanyEvaluation.find params[:company_evaluation_id]
      evaluation_user_capability_ids = policy_scope(EvaluationUserCapability)
        .joins(:company_evaluation_template)
        .where(company_evaluation_template: {company_evaluation_id: company_evaluation.id})
        .pluck(:id)
      calibration_session_users = CalibrationSessionUser
        .includes(calibration_session: [:owner, {calibration_session_judges: :judge}, :calibration_template])
        .where(evaluation_user_capability_id: evaluation_user_capability_ids)
        .distinct
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
              values << public_send(euc.company_evaluation_template.total_reverse_metric, euc.manager_scored_total_evaluation_score)
              values << public_send(euc.company_evaluation_template.total_reverse_metric, euc.final_total_evaluation_score)
              values << public_send(euc.company_evaluation_template.total_reverse_metric, euc.total_evaluation_score)
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

          temp_file = Tempfile.new("admin_excel_report")
          p.serialize temp_file
          send_file temp_file, filename: "#{company_evaluation.title}.xlsx"
        end
      end
    end

    private

    def set_breadcrumbs
      @_breadcrumbs = [
        {text: t("layouts.sidebars.admin.header"),
         link: root_path},
        {text: t("layouts.sidebars.admin.user_calibrations"),
         link: nil}
      ]
    end
  end
end
