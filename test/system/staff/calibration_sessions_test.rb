require "application_system_test_case"
require "warden/test/helpers"

class Staff::CalibrationSessionsTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    @calibration_session = calibration_sessions(:cs_two_auxiliary)
    @dragged_evaluation = evaluation_user_capabilities(:euc_pp13)
    @other_evaluation = evaluation_user_capabilities(:euc_pp12)

    login_as @calibration_session.owner, scope: :user
  end

  teardown do
    Warden.test_reset!
  end

  test "calibration owner drags an employee to another grid and saves the scores" do
    assert_nil @dragged_evaluation.calibration_performance_score
    assert_nil @dragged_evaluation.calibration_management_profession_score
    assert_nil @other_evaluation.calibration_performance_score
    assert_nil @other_evaluation.calibration_management_profession_score

    visit staff_calibration_session_path(@calibration_session, locale: "en")

    employee = find("#calibration-panel span.btn.btn-secondary", text: "PP Test 13")
    target_grid = find(
      "#calibration-panel > .row:nth-of-type(2) > .col-3",
      match: :first
    )
    employee.drag_to(target_grid)

    within target_grid do
      assert_text "PP Test 13"
    end

    click_button "Save"
    assert_text "Update success"

    assert_equal 3, @dragged_evaluation.reload.calibration_performance_score
    assert_equal 1, @dragged_evaluation.calibration_management_profession_score
    assert_equal 5, @other_evaluation.reload.calibration_performance_score
    assert_equal 5, @other_evaluation.calibration_management_profession_score
  end
end
