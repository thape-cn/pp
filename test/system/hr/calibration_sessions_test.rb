require "application_system_test_case"
require "warden/test/helpers"

class HR::CalibrationSessionsTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  teardown do
    Warden.test_reset!
  end

  test "HR opens employee details with mapped work attitude scores from the calibration square" do
    reviewer = users(:user_guochunzhong)
    reviewer.update!(preferred_language: "zh-CN")
    evaluation = evaluation_user_capabilities(:euc_supervisor_high)
    evaluation.update!(form_status: "department_calibrated", work_attitude: 3,
      calibration_work_attitude: 5, calibration_work_load: 3, calibration_work_quality: 3)
    session = CalibrationSession.create!(calibration_template: calibration_templates(:ct_one_staff_enforce),
      owner: users(:user_pptest10), hr_reviewer: reviewer, session_status: "proofreading")
    session.calibration_session_users.create!(user: evaluation.user, evaluation_user_capability: evaluation)
    login_as reviewer, scope: :user

    visit square_hr_calibration_session_path(session, locale: "zh-CN")

    find("span.btn", text: evaluation.user.chinese_name).find("a").click

    within "#coreuiModal.show" do
      assert_selector ".modal-title", text: evaluation.user.chinese_name
      within ".card", text: /\A工作态度\s/ do
        assert_selector ".card-text", exact_text: "符合标准"
      end
      within ".card", text: /\A校准后的工作态度\s/ do
        assert_selector ".card-text", exact_text: "超出标准"
      end
    end
  end

  test "HR sees annual output on the performance scale in calibration square details" do
    reviewer = users(:user_guochunzhong)
    reviewer.update!(preferred_language: "zh-CN")
    session = calibration_sessions(:cs_two_auxiliary)
    session.update!(hr_reviewer: reviewer, session_status: "proofreading")
    evaluation = evaluation_user_capabilities(:euc_pp13)
    evaluation.company_evaluation_template.update!(
      performance_metric: "grading_3_metric",
      professional_management_metric: "grading_9_metric"
    )
    login_as reviewer, scope: :user

    {5 => "超出标准", 3 => "符合标准", 1 => "低于标准", 4.5 => "4.5"}.each do |score, label|
      evaluation.update!(annual_output: score)
      visit square_hr_calibration_session_path(session, locale: "zh-CN")

      find("span.btn", text: evaluation.user.chinese_name).find("a").click

      within "#coreuiModal.show" do
        within ".card", text: /\A年度工作产出\s/ do
          assert_selector ".card-text", exact_text: label
        end
        within ".card", text: /\A专业水平\s/ do
          assert_selector ".card-text", exact_text: "5.0"
        end
      end
    end
  end
end
