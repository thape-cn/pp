require "test_helper"

class Staff::SigningControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @hr_user = users(:user_fangzixue)
    @evaluation = evaluation_user_capabilities(:euc_pp6)
    @evaluation.update!(form_status: "data_locked")
    @hr_user.hr_user_managed_companies.create!(managed_company: @evaluation.company)
    sign_in @hr_user
  end

  test "HR can open and print a historical evaluation after an employee transfers" do
    user_job_roles(:ujr_3647).update!(company: "Another company")

    assert_history_signing_and_printing_access
  end

  test "HR can open and print a historical evaluation without an active job role" do
    user_job_roles(:ujr_3647).update!(is_active: false)

    assert_history_signing_and_printing_access
  end

  private

  def assert_history_signing_and_printing_access
    get hr_company_evaluation_history_user_capabilities_path(@evaluation.company_evaluation_template.company_evaluation)

    assert_response :success
    assert_select "a[href=?]", staff_signing_path(@evaluation), text: @evaluation.user.chinese_name

    get staff_signing_path(@evaluation)

    assert_response :success
    assert_includes response.body, @evaluation.user.chinese_name

    get staff_printing_path(@evaluation)

    assert_response :success
    assert_includes response.body, @evaluation.user.chinese_name
  end
end
