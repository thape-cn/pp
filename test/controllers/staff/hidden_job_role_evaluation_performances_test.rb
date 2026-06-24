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

  test "reviewer cannot see hidden rank performances in evaluation page" do
    @evaluation_user_capability.update!(form_status: "initial")
    sign_in users(:user_pptest3)

    get staff_evaluation_path(@evaluation_user_capability)

    assert_response :success
    assert_includes response.body, @visible_performance.obj_name
    assert_not_includes response.body, @hidden_performance.obj_name
  end

  test "reviewer cannot see hidden rank performances in signing page" do
    sign_in users(:user_pptest3)

    get staff_signing_path(@evaluation_user_capability)

    assert_response :success
    assert_includes response.body, @visible_performance.obj_name
    assert_not_includes response.body, @hidden_performance.obj_name
  end

  test "reviewer cannot see hidden rank performances in printing page" do
    sign_in users(:user_pptest3)

    get staff_printing_path(@evaluation_user_capability)

    assert_response :success
    assert_includes response.body, @visible_performance.obj_name
    assert_not_includes response.body, @hidden_performance.obj_name
  end

  test "pdf renderer cannot see hidden rank performances after signing in as admin" do
    get staff_printing_path(@evaluation_user_capability), headers: {"REMOTE_ADDR" => "::1"}

    assert_response :success
    assert_includes response.body, @visible_performance.obj_name
    assert_not_includes response.body, @hidden_performance.obj_name
  end

  test "admin can see hidden rank performances in all evaluation pages" do
    sign_in users(:user_guochunzhong)

    get staff_in_evaluation_path(@evaluation_user_capability)

    assert_response :success
    assert_includes response.body, @visible_performance.obj_name
    assert_includes response.body, @hidden_performance.obj_name

    @evaluation_user_capability.update!(form_status: "initial")
    get staff_evaluation_path(@evaluation_user_capability)

    assert_response :success
    assert_includes response.body, @visible_performance.obj_name
    assert_includes response.body, @hidden_performance.obj_name

    get staff_signing_path(@evaluation_user_capability)

    assert_response :success
    assert_includes response.body, @visible_performance.obj_name
    assert_includes response.body, @hidden_performance.obj_name

    get staff_printing_path(@evaluation_user_capability)

    assert_response :success
    assert_includes response.body, @visible_performance.obj_name
    assert_includes response.body, @hidden_performance.obj_name
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

  test "evaluation capability json exposes client-facing performance metric keys" do
    sign_in users(:user_pptest3)

    get staff_evaluation_user_capability_path(@evaluation_user_capability, format: :json)

    assert_response :success
    evaluation_user_capability = response.parsed_body.fetch("evaluation_user_capability")
    assert_equal @evaluation_user_capability.manager_user_id, evaluation_user_capability.fetch("manager_user_id")
    assert_equal @evaluation_user_capability.manager_user.chinese_name, evaluation_user_capability.fetch("manager_user_name")

    metrics = evaluation_user_capability.fetch("job_role_performance_metrics")
    assert_equal "rank_performance_metric", metrics.fetch(@hidden_performance.obj_name)
    assert_equal "performance_metric", metrics.fetch(@visible_performance.obj_name)
  end
end
