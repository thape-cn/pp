require "test_helper"

class JobRoleEvaluationPerformanceTest < ActiveSupport::TestCase
  test "visible in staff review excludes hidden rank performance columns" do
    evaluation_user_capability = evaluation_user_capabilities(:euc_two)
    shared_attributes = {
      user: evaluation_user_capability.user,
      company_evaluation: evaluation_user_capability.company_evaluation_template.company_evaluation,
      dept_code: evaluation_user_capability.dept_code,
      st_code: evaluation_user_capability.job_role.st_code,
      obj_metric: "metric",
      obj_name: "performance",
      obj_weight_pct: 100
    }

    hidden_performance = JobRoleEvaluationPerformance.create!(
      **shared_attributes,
      import_guid: "hidden-performance-data",
      en_name: JobRoleEvaluationPerformance::HIDDEN_RANK_EN_NAMES.first
    )
    visible_performance = JobRoleEvaluationPerformance.create!(
      **shared_attributes,
      import_guid: "visible-performance-data",
      en_name: "p_customer"
    )
    unnamed_performance = JobRoleEvaluationPerformance.create!(
      **shared_attributes,
      import_guid: "unnamed-performance-data",
      en_name: nil
    )

    staff_review_performances = JobRoleEvaluationPerformance
      .performance_from_evaluation_user_capability(evaluation_user_capability)
      .visible_in_staff_review

    assert_includes staff_review_performances, visible_performance
    assert_includes staff_review_performances, unnamed_performance
    refute_includes staff_review_performances, hidden_performance
  end

  test "hidden rank en name predicate matches configured rank performance columns" do
    assert JobRoleEvaluationPerformance.hidden_rank_en_name?("p_managedproject_profit")
    assert_not JobRoleEvaluationPerformance.hidden_rank_en_name?("p_customer")
  end
end
