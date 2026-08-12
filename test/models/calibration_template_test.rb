require "test_helper"

class CalibrationTemplateTest < ActiveSupport::TestCase
  test "requires a company evaluation template" do
    calibration_template = CalibrationTemplate.new

    assert_not calibration_template.valid?
    assert calibration_template.errors.of_kind?(:company_evaluation_templates, :blank)
  end

  test "belongs to multiple company evaluation templates through the join model" do
    calibration_template = calibration_templates(:ct_one_staff_enforce)
    additional_template = company_evaluation_templates(:ect_supervisor_high)

    calibration_template.company_evaluation_templates << additional_template

    assert_equal [
      company_evaluation_templates(:ect_staff),
      additional_template
    ].sort_by(&:id), calibration_template.company_evaluation_templates.reload.sort_by(&:id)
    assert_includes additional_template.calibration_templates, calibration_template
  end

  test "belongs to one company evaluation" do
    calibration_template = calibration_templates(:ct_one_staff_enforce)

    assert_equal company_evaluations(:ce_one), calibration_template.company_evaluation
  end

  test "cannot link to an evaluation template from another company evaluation" do
    calibration_template = calibration_templates(:ct_one_staff_enforce)
    other_company_evaluation_template = CompanyEvaluationTemplate.create!(
      company_evaluation: company_evaluations(:ce_two),
      title: "Other evaluation template",
      group_level: "staff"
    )

    assert_raises ActiveRecord::RecordInvalid do
      calibration_template.company_evaluation_templates << other_company_evaluation_template
    end
    assert_not_includes calibration_template.company_evaluation_templates.reload, other_company_evaluation_template
  end

  test "cannot move to another company evaluation while linked" do
    calibration_template = calibration_templates(:ct_one_staff_enforce)

    calibration_template.company_evaluation = company_evaluations(:ce_two)

    assert_not calibration_template.valid?
    assert_includes calibration_template.errors[:company_evaluation_templates],
      "must belong to the same company evaluation"
  end

  test "hamilton_method calculates correct seat allocations case 343" do
    populations = {below_standard_rate: 30, standards_compliant_rate: 40, beyond_standard_rate: 30}
    seats = 15
    expected_result = {below_standard_rate: 5, standards_compliant_rate: 6, beyond_standard_rate: 4}
    assert_equal expected_result, CalibrationTemplate.hamilton_method(populations, seats)
  end

  test "hamilton_method calculates correct seat allocations case 361" do
    populations = {apa_grade_rate: 30, b_grade_rate: 60, cd_grade_rate: 10}
    seats = 16
    expected_result = {apa_grade_rate: 5, b_grade_rate: 10, cd_grade_rate: 1}
    assert_equal expected_result, CalibrationTemplate.hamilton_method(populations, seats)
  end
end
