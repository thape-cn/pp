module Admin
  class UserCalibrationsController < BaseController
    include MetricHelper
    include Pagy::Method

    after_action :verify_authorized, except: %i[index excel_report]
    after_action :verify_policy_scoped, only: %i[index excel_report]
    before_action :set_breadcrumbs, if: -> { request.format.html? }

    def index
      @company_evaluation = CompanyEvaluation.find params[:company_evaluation_id]
      title = t(".breadcrumb_title", title: @company_evaluation.title)
      add_to_breadcrumbs title
      set_meta_tags(title: title)
      calibration_session_users = policy_scope(CalibrationSessionUser)
        .includes(:user, {calibration_session: {calibration_template: :company_evaluation}})
        .where(calibration_session: {calibration_template: {company_evaluation_id: @company_evaluation.id}})
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
      @pagy, @calibration_session_users = pagy(:offset, calibration_session_users, limit: current_user.preferred_page_length)
    end

    def excel_report
      enqueue_report_export("admin_calibrations")
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
