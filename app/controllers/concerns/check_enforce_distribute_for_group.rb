module CheckEnforceDistributeForGroup
  extend ActiveSupport::Concern

  private

  def check_enforce_distribute_for_staff_group(calibration)
    lower_quotas_staff = @calibration_session.lower_quotas_staff
    ct = @calibration_session.calibration_template
    apa_grade_rate_people_count = calibration["13"]&.length.to_i + calibration["12"]&.length.to_i + calibration["23"]&.length.to_i
    b_grade_rate_people_count = calibration["11"]&.length.to_i + calibration["22"]&.length.to_i + calibration["33"]&.length.to_i
    cd_grade_rate_people_count = calibration["31"]&.length.to_i + calibration["21"]&.length.to_i + calibration["32"]&.length.to_i
    if lower_quotas_staff[:apa_grade_rate] == apa_grade_rate_people_count \
      && lower_quotas_staff[:b_grade_rate] == b_grade_rate_people_count \
      && lower_quotas_staff[:cd_grade_rate] == cd_grade_rate_people_count
      nil
    else
      I18n.t("calibration.enforce_distribute_for_staff_failure", apa_grade_rate: ct.apa_grade_rate,
        b_grade_rate: ct.b_grade_rate, cd_grade_rate: ct.cd_grade_rate)
    end
  end

  def check_enforce_distribute_for_manager_group(calibration)
    lower_quotas_manager = @calibration_session.lower_quotas_manager
    ct = @calibration_session.calibration_template
    below_standard_rate_people_count = calibration["11"]&.length.to_i + calibration["21"]&.length.to_i + calibration["31"]&.length.to_i
    standards_compliant_rate_people_count = calibration["12"]&.length.to_i + calibration["22"]&.length.to_i + calibration["32"]&.length.to_i
    beyond_standard_rate_people_count = calibration["13"]&.length.to_i + calibration["23"]&.length.to_i + calibration["33"]&.length.to_i
    if lower_quotas_manager[:below_standard_rate] == below_standard_rate_people_count \
      && lower_quotas_manager[:standards_compliant_rate] == standards_compliant_rate_people_count \
      && lower_quotas_manager[:beyond_standard_rate] == beyond_standard_rate_people_count
      nil
    else
      I18n.t("calibration.enforce_distribute_for_manager_failure", below_standard_rate: ct.below_standard_rate,
        standards_compliant_rate: ct.standards_compliant_rate, beyond_standard_rate: ct.beyond_standard_rate)
    end
  end
end
