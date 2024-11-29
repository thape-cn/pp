json.array! need_calibration_eucs do |euc|
  json.id_user euc.user_id
  json.chinese_name euc.user.chinese_name
  json.title euc.title
  json.department euc.department
  json.form_status_name EvaluationUserCapability.form_status_options.invert[euc.form_status]

  Capability.performance_column_names.each do |performance_column_name|
    json.set! performance_column_name, euc.attributes[performance_column_name]&.to_f&.round(1) || "none"
    json.set! "#{performance_column_name}_fixed", true
  end
  json.calibration_work_quality euc.calibration_work_quality || "none"
  json.calibration_work_quality_fixed true
  json.calibration_work_load euc.calibration_work_load || "none"
  json.calibration_work_load_fixed true
  json.calibration_work_attitude euc.calibration_work_attitude || "none"
  json.calibration_work_attitude_fixed true
  json.calibration_management_profession_score euc.calibration_management_profession_score || "none"
  json.calibration_performance_score euc.calibration_performance_score || "none"
  json.calibration_profession_score euc.calibration_profession_score || "none"
  json.calibration_management_score euc.calibration_management_score || "none"
  Capability.management_column_names.each do |management_column_name|
    json.set! management_column_name, euc.attributes[management_column_name]&.to_f&.round(1) || "none"
    json.set! "#{management_column_name}_fixed", true
  end
  Capability.profession_column_names.each do |profession_column_name|
    json.set! profession_column_name, euc.attributes[profession_column_name]&.to_f&.round(1) || "none"
    json.set! "#{profession_column_name}_fixed", true
  end
  json.id_cet euc.company_evaluation_template_id
  table_headers_of_performance.each do |h|
    jrep = job_role_evaluation_performances.find { |jrep| jrep.en_name == h[:accessor] && jrep.user_id == euc.user_id && jrep.dept_code == euc.dept_code && jrep.st_code == euc.job_role.st_code }
    json.set! h[:accessor], jrep&.obj_result || "none"
    json.set! "#{h[:accessor]}_fixed", true
    json.set! "#{h[:accessor]}_id", jrep&.id
  end
  json.id_euc euc.id
  json.raw_total_evaluation_score euc.raw_total_evaluation_score
  json.raw_total_score_in_metric euc.raw_total_score_in_metric
  json.total_evaluation_score euc.total_evaluation_score
  json.total_score_in_metric euc.total_score_in_metric
end
