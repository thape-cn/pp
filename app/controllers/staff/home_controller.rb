module Staff
  class HomeController < BaseController
    def index
      @company_evaluation_ids = CompanyEvaluation.open_for_user.pluck(:id)
      current_open_evaluations = policy_scope(EvaluationUserCapability)
        .joins(:company_evaluation_template)
        .where(company_evaluation_template: {company_evaluation_id: @company_evaluation_ids})
      @need_complete_evaluations = current_open_evaluations
        .where(user_id: current_user.id, form_status: "initial")
      @need_review_evaluations = current_open_evaluations
        .where(manager_user_id: current_user.id)
        .where(form_status: "self_assessment_done")
      @need_calibration_sessions = CalibrationSession.where(owner_id: current_user.id).or(CalibrationSession.where(hr_reviewer_id: current_user.id))
        .left_joins(:calibration_session_judges)
        .or(CalibrationSession.left_joins(:calibration_session_judges).where(calibration_session_judges: {judge_id: current_user.id}))
        .where(session_status: "calibrating")
        .distinct
        .reject { |cs| cs.calibration_template.company_evaluation_template.company_evaluation.evaluation_ended? }

      @proofreading_calibration_sessions = CalibrationSession
        .where(session_status: "proofreading", hr_reviewer_id: current_user.id)
        .where(calibration_template_id: CalibrationTemplate.open_for_user_calibration_template_ids)
        .distinct
      @need_signing_evaluations = current_open_evaluations
        .where(user_id: current_user.id, form_status: "hr_review_completed")
    end

    protected

    def set_page_layout_data
      super
      @skip_title = true
    end
  end
end
