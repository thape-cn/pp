json.company_evaluation_template do
  cet = @evaluation_user_capability.company_evaluation_template
  json.set! :work_quality_metric do
    json.array! public_send(cet.work_quality_metric) do |k|
      json.label k.first
      json.value k.second
    end
  end
  json.set! :work_load_metric do
    json.array! public_send(cet.work_load_metric) do |k|
      json.label k.first
      json.value k.second
    end
  end
  json.set! :work_attitude_metric do
    json.array! public_send(cet.work_attitude_metric) do |k|
      json.label k.first
      json.value k.second
    end
  end
  json.set! :professional_management_metric do
    json.array! public_send(cet.professional_management_metric) do |k|
      json.label k.first
      json.value k.second
    end
  end
  json.set! :performance_metric do
    json.array! public_send(cet.performance_metric) do |k|
      json.label k.first
      json.value k.second
    end
  end
end
json.evaluation_user_capability do
  json.id @evaluation_user_capability.id
  json.chinese_name @evaluation_user_capability.user.chinese_name
  json.form_status EvaluationUserCapability.form_status_options.invert[@evaluation_user_capability.form_status]
  json.fixed_output do
    Capability.performance_column_names.each do |performance_column_name|
      json.set! performance_column_name, @evaluation_user_capability.attributes[performance_column_name].to_f.round(1) if @evaluation_user_capability.attributes[performance_column_name].present?
    end
  end
  json.management_capability do
    Capability.management_column_label_and_names.each do |c|
      json.set! c.first, @evaluation_user_capability.attributes[c.second].to_f.round(1) if @evaluation_user_capability.attributes[c.second].present?
    end
  end
  json.profession_capability do
    Capability.profession_column_label_and_names.each do |c|
      json.set! c.first, @evaluation_user_capability.attributes[c.second].to_f.round(1) if @evaluation_user_capability.attributes[c.second].present?
    end
  end
  json.job_role_performances do
    @job_role_performances.each do |jrep|
      json.set! jrep.obj_name, jrep.obj_result if jrep.obj_result.present?
    end
  end
  json.self_overall_output markdown(@evaluation_user_capability.self_overall_output)
  json.self_overall_improvement markdown(@evaluation_user_capability.self_overall_improvement)
  json.self_overall_plan markdown(@evaluation_user_capability.self_overall_plan)
  json.manager_overall_output markdown(@evaluation_user_capability.manager_overall_output)
  json.manager_overall_output_hint markdown(@company_evaluation_template.manager_overall_output_hint)
  json.manager_overall_improvement markdown(@evaluation_user_capability.manager_overall_improvement)
  json.manager_overall_improvement_hint markdown(@company_evaluation_template.manager_overall_improvement_hint)
  json.manager_overall_plan markdown(@evaluation_user_capability.manager_overall_plan)
  json.manager_overall_plan_hint markdown(@company_evaluation_template.manager_overall_plan_hint)
  json.edit_manager_overall_output @evaluation_user_capability.manager_overall_output || ""
  json.edit_manager_overall_improvement @evaluation_user_capability.manager_overall_improvement || ""
  json.edit_manager_overall_plan @evaluation_user_capability.manager_overall_plan || ""
end
