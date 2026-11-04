require "test_helper"

class Admin::UserCalibrationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:user_guochunzhong)
    @company_evaluation = company_evaluations(:ce_one)
    @session_user = calibration_session_users(:cs_one_staff_u1)
  end

  test "index only lists calibrations from the requested company evaluation" do
    other_session_user = create_other_evaluation_calibration

    get admin_company_evaluation_user_calibrations_path(company_evaluation_id: @company_evaluation.id)

    assert_response :success
    assert_select "tbody tr", count: 3
    assert_select "tbody td:first-child span", text: @session_user.user.chinese_name
    assert_select "tbody td:first-child span", text: other_session_user.user.chinese_name, count: 0

    get admin_company_evaluation_user_calibrations_path(company_evaluation_id: company_evaluations(:ce_two).id)

    assert_response :success
    assert_select "tbody tr", count: 1
    assert_select "tbody td:first-child span", text: other_session_user.user.chinese_name
  end

  test "index filters calibrations by user" do
    get admin_company_evaluation_user_calibrations_path(company_evaluation_id: @company_evaluation.id), params: {
      user_id: @session_user.user_id
    }

    assert_response :success
    assert_select "tbody tr", count: 1
    assert_select "tbody td:first-child span", text: @session_user.user.chinese_name
  end

  test "index filters calibrations without an evaluation" do
    @session_user.update_column(:evaluation_user_capability_id, EvaluationUserCapability.maximum(:id) + 1)

    get admin_company_evaluation_user_calibrations_path(company_evaluation_id: @company_evaluation.id), params: {
      select_no_evaluation_user_capability: "true"
    }

    assert_response :success
    assert_select "tbody tr", count: 1
    assert_select "tbody td:first-child span.bg-danger-gradient", text: @session_user.user.chinese_name
  end

  test "index combines the user and missing evaluation filters" do
    @session_user.update_column(:evaluation_user_capability_id, EvaluationUserCapability.maximum(:id) + 1)

    get admin_company_evaluation_user_calibrations_path(company_evaluation_id: @company_evaluation.id), params: {
      user_id: users(:user_pptest12).id,
      select_no_evaluation_user_capability: "true"
    }

    assert_response :success
    assert_select "tbody tr", count: 0
  end

  private

  def create_other_evaluation_calibration
    evaluation_template = CompanyEvaluationTemplate.create!(
      company_evaluation: company_evaluations(:ce_two),
      title: "Other evaluation template",
      group_level: "staff"
    )
    calibration_template = CalibrationTemplate.create!(
      company_evaluation: company_evaluations(:ce_two),
      company_evaluation_templates: [evaluation_template],
      template_name: "Other calibration template"
    )
    session = CalibrationSession.create!(
      calibration_template: calibration_template,
      owner: users(:user_pptest10),
      session_name: "Other calibration session"
    )
    evaluation = @session_user.evaluation_user_capability.dup
    evaluation.company_evaluation_template = evaluation_template
    evaluation.user = users(:user_pptest0)
    evaluation.save!
    session.calibration_session_users.create!(user: evaluation.user, evaluation_user_capability: evaluation)
  end
end
