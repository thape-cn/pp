require "test_helper"

class CompanyEvaluationTemplateTest < ActiveSupport::TestCase
  EvaluationStub = Struct.new(
    :group_of_staff_work_load,
    :group_of_staff_work_quality_and_work_attitude,
    :group_of_manager_performance,
    :group_of_manager_management_profession,
    :group_of_manager_only_profession,
    :group_of_manager_only_management,
    :work_attitude
  )

  def supervisor_template
    CompanyEvaluationTemplate.new(group_level: "supervisor")
  end

  test "mark score group options describe staff grade bands" do
    assert_equal(
      {
        ">= 10,11 级" => 4,
        "9 级" => 3,
        "7,8 级" => 2,
        "<= 6 级" => 1
      },
      CompanyEvaluationTemplate.mark_score_group_options
    )
  end

  test "distribution predicates describe calibration quota families" do
    assert company_evaluation_templates(:ect_staff).staff_distribution?
    assert company_evaluation_templates(:ect_auxiliary).staff_distribution?
    assert supervisor_template.staff_distribution?
    assert CompanyEvaluationTemplate.new(group_level: "manager_b").staff_distribution?

    assert company_evaluation_templates(:ect_manager).manager_distribution?
    assert_not company_evaluation_templates(:ect_staff).manager_distribution?
    assert_not supervisor_template.manager_distribution?
  end

  test "performance columns are excluded only for manager b" do
    assert company_evaluation_templates(:ect_staff).includes_performance_columns?
    assert company_evaluation_templates(:ect_auxiliary).includes_performance_columns?
    assert supervisor_template.includes_performance_columns?
    assert company_evaluation_templates(:ect_manager).includes_performance_columns?
    assert_not CompanyEvaluationTemplate.new(group_level: "manager_b").includes_performance_columns?
  end

  test "calibration table partial follows staff versus manager table layout" do
    assert_equal "ui/calibration_sessions/staff_table", company_evaluation_templates(:ect_staff).calibration_table_partial
    assert_equal "ui/calibration_sessions/manager_table", company_evaluation_templates(:ect_auxiliary).calibration_table_partial
    assert_equal "ui/calibration_sessions/staff_table", supervisor_template.calibration_table_partial
    assert_equal "ui/calibration_sessions/manager_table", company_evaluation_templates(:ect_manager).calibration_table_partial
    assert_equal "ui/calibration_sessions/manager_table", CompanyEvaluationTemplate.new(group_level: "manager_b").calibration_table_partial
  end

  test "grouping positions are selected by group level" do
    euc = EvaluationStub.new(
      group_of_staff_work_load: 1,
      group_of_staff_work_quality_and_work_attitude: 2,
      group_of_manager_performance: 3,
      group_of_manager_management_profession: 1,
      group_of_manager_only_profession: 2,
      group_of_manager_only_management: 3
    )

    assert_equal ["12"], company_evaluation_templates(:ect_staff).group_evaluation_user_capabilities([euc]).keys
    assert_equal ["31"], company_evaluation_templates(:ect_auxiliary).group_evaluation_user_capabilities([euc]).keys
    assert_equal ["12"], supervisor_template.group_evaluation_user_capabilities([euc]).keys
    assert_equal ["31"], company_evaluation_templates(:ect_manager).group_evaluation_user_capabilities([euc]).keys
    assert_equal ["23"], CompanyEvaluationTemplate.new(group_level: "manager_b").group_evaluation_user_capabilities([euc]).keys
  end

  test "calibration square updates map to the correct score fields" do
    euc = EvaluationStub.new(work_attitude: 2)

    assert_equal(
      {calibration_work_quality: 5, calibration_work_load: 5, calibration_work_attitude: 2},
      company_evaluation_templates(:ect_staff).calibration_attributes_for_square("13", euc)
    )
    assert_equal(
      {calibration_management_profession_score: 1, calibration_performance_score: 1},
      company_evaluation_templates(:ect_auxiliary).calibration_attributes_for_square("31", euc)
    )
    assert_equal(
      {calibration_work_quality: 1, calibration_work_load: 1, calibration_work_attitude: 2},
      supervisor_template.calibration_attributes_for_square("31", euc)
    )
    assert_equal(
      {calibration_management_profession_score: 3, calibration_performance_score: 5},
      company_evaluation_templates(:ect_manager).calibration_attributes_for_square("12", euc)
    )
    assert_equal(
      {calibration_management_score: 3, calibration_profession_score: 3},
      CompanyEvaluationTemplate.new(group_level: "manager_b").calibration_attributes_for_square("22", euc)
    )
  end

  test "job role performance metric uses rank metric for rank performance columns" do
    template = company_evaluation_templates(:ect_staff)
    rank_performance = JobRoleEvaluationPerformance.new(en_name: "p_individual_hours")
    output_performance = JobRoleEvaluationPerformance.new(en_name: "p_customer")

    assert_equal "rank_performance_metric", template.job_role_performance_metric_key(rank_performance)
    assert_equal "performance_metric", template.job_role_performance_metric_key(output_performance)
    assert_equal template.rank_performance_metric, template.job_role_performance_metric(rank_performance)
    assert_equal template.performance_metric, template.job_role_performance_metric(output_performance)
  end
end
