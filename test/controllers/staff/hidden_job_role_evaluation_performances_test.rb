require "test_helper"

class Staff::HiddenJobRoleEvaluationPerformancesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @evaluation_user_capability = evaluation_user_capabilities(:euc_pp6)
    shared_attributes = {
      user: @evaluation_user_capability.user,
      company_evaluation: @evaluation_user_capability.company_evaluation_template.company_evaluation,
      dept_code: @evaluation_user_capability.dept_code,
      st_code: @evaluation_user_capability.job_role.st_code,
      obj_metric: "metric",
      obj_weight_pct: 50,
      obj_result_fixed: false,
      obj_result: 1
    }

    @hidden_performance = JobRoleEvaluationPerformance.create!(
      **shared_attributes,
      import_guid: "hidden-performance-for-staff-controller",
      obj_name: "Hidden staff review performance",
      en_name: JobRoleEvaluationPerformance::HIDDEN_RANK_EN_NAMES.first
    )
    @visible_performance = JobRoleEvaluationPerformance.create!(
      **shared_attributes,
      import_guid: "visible-performance-for-staff-controller",
      obj_name: "Visible staff review performance",
      en_name: "p_customer"
    )
  end

  test "reviewed staff user cannot see hidden rank performances in in evaluation page" do
    sign_in @evaluation_user_capability.user

    get staff_in_evaluation_path(@evaluation_user_capability)

    assert_response :success
    assert_includes response.body, @visible_performance.obj_name
    assert_not_includes response.body, @hidden_performance.obj_name
  end

  test "reviewer cannot see hidden rank performances in in evaluation page" do
    sign_in users(:user_pptest3)

    get staff_in_evaluation_path(@evaluation_user_capability)

    assert_response :success
    assert_includes response.body, @visible_performance.obj_name
    assert_not_includes response.body, @hidden_performance.obj_name
  end

  test "reviewed staff user cannot fetch hidden rank performance detail directly" do
    sign_in @evaluation_user_capability.user

    get staff_user_job_role_performance_path(@hidden_performance, format: :json)

    assert_response :not_found
  end

  test "reviewer can still fetch hidden rank performance detail" do
    sign_in users(:user_pptest3)

    get staff_user_job_role_performance_path(@hidden_performance, format: :json)

    assert_response :success
    assert_includes response.body, @hidden_performance.obj_name
  end
end
