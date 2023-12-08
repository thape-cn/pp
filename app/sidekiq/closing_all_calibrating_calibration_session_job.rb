class ClosingAllCalibratingCalibrationSessionJob
  include Sidekiq::Job

  def perform(company_evaluation_id)
    to_close_calibration_session_ids = CalibrationSessionUser.includes(evaluation_user_capability: :company_evaluation_template)
      .where(evaluation_user_capability: {company_evaluation_templates: {company_evaluation_id: company_evaluation_id}})
      .pluck(:calibration_session_id)
    to_close_calibration_sessions = CalibrationSession.where(id: to_close_calibration_session_ids, session_status: 'proofreading')
    to_close_calibration_sessions.update_all(session_status: 'reconciliation_needed')
  end
end
