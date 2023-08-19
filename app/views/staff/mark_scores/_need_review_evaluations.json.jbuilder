json.array! need_review_evaluations.includes(:job_role, :user) do |euc|
  json.id_user euc.user_id
  json.chinese_name euc.user.chinese_name
  json.title euc.title
  json.department euc.department
  json.form_status_name EvaluationUserCapability.form_status_options.invert[euc.form_status]

  Capability.performance_column_names.each do |performance_column_name|
    json.set! performance_column_name, euc.attributes[performance_column_name]&.to_f&.round(1) || "none"
  end
  Capability.management_column_names.each do |management_column_name|
    json.set! management_column_name, euc.attributes[management_column_name]&.to_f&.round(1) || "none"
  end
  Capability.profession_column_names.each do |profession_column_name|
    json.set! profession_column_name, euc.attributes[profession_column_name]&.to_f&.round(1) || "none"
  end
  json.id_cet euc.company_evaluation_template_id
  table_headers_of_performance.each do |h|
    jrep = job_role_evaluation_performances.find { |jrep| jrep.en_name == h[:accessor] && jrep.user_id == euc.user_id && jrep.dept_code == euc.dept_code && jrep.st_code == euc.job_role.st_code }
    json.set! h[:accessor], jrep&.obj_result || "none"
    json.set! "#{h[:accessor]}_fixed", jrep&.obj_result_fixed
    json.set! "#{h[:accessor]}_id", jrep&.id
  end
  json.id_euc euc.id
  json.pre_total_evaluation_score euc.pre_total_evaluation_score
end
