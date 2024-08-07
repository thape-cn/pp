module CP
  class HomeController < BaseController
    def index
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

      respond_to do |format|
        format.html { render }
      end
    end

    protected

    def set_page_layout_data
      super
      @skip_title = true
    end
  end
end
