json.calibration_sessions_path staff_calibration_session_path(id: @calibration_session.id)
json.need_calibration_eucs do
  json.partial! "need_calibration_eucs", locals: {need_calibration_eucs: @need_calibration_eucs, table_headers_of_performance: @table_headers_of_performance, job_role_evaluation_performances: @job_role_evaluation_performances}
end
