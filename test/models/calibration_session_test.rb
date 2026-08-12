require "test_helper"

class CalibrationSessionTest < ActiveSupport::TestCase
  test "resolves the company evaluation template from its evaluation users" do
    calibration_session = calibration_sessions(:cs_one_staff)

    assert_equal company_evaluation_templates(:ect_staff), calibration_session.company_evaluation_template
  end

  test "cannot use a calibration template from another company evaluation" do
    calibration_session = calibration_sessions(:cs_one_staff)
    other_company_evaluation_template = CompanyEvaluationTemplate.create!(
      company_evaluation: company_evaluations(:ce_two),
      title: "Other evaluation template",
      group_level: "staff"
    )
    other_calibration_template = CalibrationTemplate.create!(
      company_evaluation: company_evaluations(:ce_two),
      company_evaluation_templates: [other_company_evaluation_template],
      template_name: "Other calibration template"
    )

    calibration_session.calibration_template = other_calibration_template

    assert_not calibration_session.valid?
    assert_includes calibration_session.errors[:calibration_template],
      "must belong to the calibration users' company evaluation"
  end
end
