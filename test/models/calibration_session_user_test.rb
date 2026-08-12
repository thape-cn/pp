require "test_helper"

class CalibrationSessionUserTest < ActiveSupport::TestCase
  test "cannot join a session from another company evaluation" do
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
    other_calibration_session = CalibrationSession.create!(
      calibration_template: other_calibration_template,
      owner: users(:user_pptest10),
      session_name: "Other calibration session"
    )
    calibration_session_user = CalibrationSessionUser.new(
      calibration_session: other_calibration_session,
      user: users(:user_pptest11),
      evaluation_user_capability: evaluation_user_capabilities(:euc_pp11)
    )

    assert_not calibration_session_user.valid?
    assert_includes calibration_session_user.errors[:calibration_session],
      "must use a calibration template from the user's company evaluation"
  end
end
