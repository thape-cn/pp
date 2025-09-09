module HR
  class HomeController < BaseController
    include ExcelExport
    include Pagy::Backend

    helper_method :pagy

    def index
      @display_label = params[:label].presence
      @display_form_status = EvaluationUserCapability.form_status_options[@display_label]
      @company_evaluations = policy_scope(CompanyEvaluation).open_for_user
      @company_evaluation_ids = @company_evaluations.pluck(:id)

      current_open_evaluations = policy_scope(EvaluationUserCapability)
        .joins(:company_evaluation_template)
        .where(company_evaluation_template: {company_evaluation_id: @company_evaluation_ids})
      @need_complete_evaluations = current_open_evaluations
        .where(user_id: current_user.id, form_status: "initial")
      @need_review_evaluations = current_open_evaluations
        .where(manager_user_id: current_user.id)
        .where(form_status: "self_assessment_done")
      @need_calibration_sessions = policy_scope(CalibrationSession)
        .where(session_status: "calibrating")
        .where(calibration_template_id: CalibrationTemplate.open_for_user_calibration_template_ids)
        .distinct
      @need_signing_evaluations = current_open_evaluations
        .where(user_id: current_user.id, form_status: "hr_review_completed")

      @proofreading_calibration_sessions = policy_scope(CalibrationSession)
        .where(session_status: "proofreading")
        .where(calibration_template_id: CalibrationTemplate.open_for_user_calibration_template_ids)
        .distinct
      @evaluation_user_capabilities = policy_scope(EvaluationUserCapability)
        .includes(:company_evaluation_template, :user, :manager_user)
        .where(company_evaluation_template: {company_evaluation_id: @company_evaluation_ids})

      respond_to do |format|
        format.html { render }
        format.xlsx do
          send_file evaluation_progress_excel_file(@evaluation_user_capabilities),
            filename: "hr_evaluation_progress.xlsx"
        end
      end
    end

    protected

    def set_page_layout_data
      super
      @skip_title = true
    end
  end
end
