require "application_system_test_case"
require "warden/test/helpers"

class Staff::CalibrationTableSessionsTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    @calibration_session = calibration_sessions(:cs_one_staff)
    @evaluation = evaluation_user_capabilities(:euc_pp11)
    @evaluation.update!(form_status: "manager_scored")
    @calibration_session.update!(session_status: "calibrating")
    login_as @calibration_session.owner, scope: :user
  end

  teardown do
    Warden.test_reset!
  end

  test "calibration owner expands an employee comment row" do
    visit staff_calibration_table_session_path(@calibration_session, locale: "zh-CN")

    within "#calibration-table" do
      employee_row = find("tbody tr", text: @evaluation.user.chinese_name)
      employee_row.all("td")[1].find("span").click

      assert_selector "tbody > tr", count: 2
      assert_text @evaluation.self_overall_output
    end
  end
end
