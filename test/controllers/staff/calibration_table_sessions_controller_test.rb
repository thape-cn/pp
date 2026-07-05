require "test_helper"

class Staff::CalibrationTableSessionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @calibration_session = calibration_sessions(:cs_one_staff)
    @evaluation_user_capability = evaluation_user_capabilities(:euc_pp11)
    @evaluation_user_capability.update!(form_status: "manager_scored")
    @calibration_session.update!(session_status: "calibrating")
    sign_in @calibration_session.owner
  end

  test "json exposes performance result explanation for calibration table cells" do
    performance = JobRoleEvaluationPerformance.create!(
      user: @evaluation_user_capability.user,
      company_evaluation: @evaluation_user_capability.company_evaluation_template.company_evaluation,
      dept_code: @evaluation_user_capability.dept_code,
      st_code: @evaluation_user_capability.job_role.st_code,
      import_guid: "calibration-table-performance-explain",
      obj_name: "Performance with explanation",
      obj_metric: "metric",
      obj_weight_pct: 100,
      en_name: "p_customer",
      obj_result_fixed: false,
      obj_result: 1,
      obj_result_explain: "calibration table result explanation"
    )

    get staff_calibration_table_session_path(@calibration_session, format: :json)

    assert_response :success
    row = response.parsed_body.fetch("need_calibration_eucs").find do |item|
      item.fetch("id_euc") == @evaluation_user_capability.id
    end
    assert_equal performance.obj_result_explain, row.fetch("p_customer_obj_result_explain")
  end
end
