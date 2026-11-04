require "application_system_test_case"
require "warden/test/helpers"

class Admin::UserCalibrationsTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    login_as users(:user_guochunzhong), scope: :user
  end

  teardown do
    Warden.test_reset!
  end

  test "admin lists calibrations and filters users without an evaluation" do
    session_user = calibration_session_users(:cs_one_staff_u1)
    session_user.update_column(:evaluation_user_capability_id, EvaluationUserCapability.maximum(:id) + 1)

    visit admin_company_evaluation_user_calibrations_path(company_evaluation_id: company_evaluations(:ce_one).id, locale: "en")

    assert_selector "tbody tr", count: 3
    check "Choose calibration without evaluation user capability"
    click_button "Confirm"

    assert_selector "tbody tr", count: 1
    within "tbody" do
      assert_text session_user.user.chinese_name
      assert_no_text users(:user_pptest12).chinese_name
    end
  end
end
