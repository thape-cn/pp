json.can_finalize policy(@calibration_session).finalize_calibration?
json.calibration_template do
  json.group_level @group_level

  calibration_template = @calibration_session.calibration_template
  json.enforce_distribute calibration_template.enforce_distribute

  lower_quotas_staff = @calibration_session.lower_quotas_staff
  json.apa_grade do
    json.grade_title t("calibration.apa_grade")
    json.lower_quota lower_quotas_staff[:apa_grade_rate]
  end
  json.b_grade do
    json.grade_title t("calibration.b_grade")
    json.lower_quota lower_quotas_staff[:b_grade_rate]
  end
  json.cd_grade do
    json.grade_title t("calibration.cd_grade")
    json.lower_quota lower_quotas_staff[:cd_grade_rate]
  end

  lower_quotas_manager = @calibration_session.lower_quotas_manager
  json.below_standard do
    json.grade_title t("evaluation.capability_below_standard")
    json.lower_quota lower_quotas_manager[:below_standard_rate]
  end
  json.standards_compliant do
    json.grade_title t("evaluation.capability_standards_compliant")
    json.lower_quota lower_quotas_manager[:standards_compliant_rate]
  end
  json.beyond_standard do
    json.grade_title t("evaluation.capability_beyond_standard")
    json.lower_quota lower_quotas_manager[:beyond_standard_rate]
  end
end
json.to_calibration_euc do
  json.partial! "to_calibration_euc",
    locals: {need_calibration_evaluation_user_capabilities: @need_calibration_evaluation_user_capabilities,
             blank_data_keys: @blank_data_keys, group_level: @group_level}
end
