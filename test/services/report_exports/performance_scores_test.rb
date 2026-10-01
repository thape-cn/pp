require "test_helper"
require_relative "../../support/report_export_helpers"

class ReportExports::PerformanceScoresTest < ActiveSupport::TestCase
  include ReportExportHelpers

  test "batch totals match individual queries for legacy records and separate business keys" do
    evaluation = evaluation_user_capabilities(:euc_pp1)
    evaluation.update_columns(dept_code: "regression-original")
    second_department = evaluation.dup
    second_department.update!(dept_code: "another-department")
    second_role = evaluation.dup
    second_role.update!(job_role: job_roles(:job_one))
    other_template = evaluation.company_evaluation_template.dup
    other_template.update!(company_evaluation: company_evaluations(:ce_two))
    second_period = evaluation.dup
    second_period.update!(company_evaluation_template: other_template)

    add_performance(evaluation, weight: 25, score: 2)
    add_performance(evaluation, weight: 75, score: 4)
    add_performance(second_department, weight: 100, score: 1)
    add_performance(second_role, weight: 100, score: 5)
    add_performance(second_period, weight: 100, score: 3)
    add_performance(evaluation, weight: 100, score: 5, user: users(:user_pptest4))

    evaluations = [evaluation, second_department, second_role, second_period]
    scores = ReportExports::PerformanceScores.for(evaluations)
    assert_equal [3.5, 1, 5, 3], evaluations.map { |record| scores.fetch(record.id).to_f }
    evaluations.each do |record|
      assert_equal record.performance_weight_upload_result, scores.fetch(record.id)
      assert_equal record.total_score_in_metric, record.total_score_in_metric(uploaded_performance_result: scores.fetch(record.id))
    end
  end

  test "missing and unscored performances produce zero without per-record queries" do
    evaluation = evaluation_user_capabilities(:euc_pp1)
    unscored = evaluation_user_capabilities(:euc_pp2)
    evaluation.update_columns(dept_code: "regression-missing")
    unscored.update_columns(dept_code: "regression-unscored")
    add_performance(unscored, weight: 100, score: nil)
    evaluations = [evaluation, unscored]
    queries = capture_queries do
      scores = ReportExports::PerformanceScores.for(evaluations)
      evaluations.each do |record|
        assert_equal 0, scores.fetch(record.id, 0)
        record.total_score_in_metric(uploaded_performance_result: scores.fetch(record.id, 0))
      end
    end
    assert_equal 1, performance_queries(queries).size
  end

  test "calibrated and annual-output scores keep their original calculations" do
    calibrated = evaluation_user_capabilities(:euc_pp1)
    calibrated.calibration_performance_score = 4
    auxiliary = evaluation_user_capabilities(:euc_pp12)
    supervisor = evaluation_user_capabilities(:euc_supervisor_high)
    evaluations = [calibrated, auxiliary, supervisor]
    queries = capture_queries do
      assert_empty ReportExports::PerformanceScores.for(evaluations)
      evaluations.each do |record|
        assert_equal record.total_score_in_metric, record.total_score_in_metric(uploaded_performance_result: 0)
      end
    end
    assert_empty performance_queries(queries)
  end

  test "admin reports aggregate performance scores once per batch" do
    %w[admin_evaluations admin_evaluation_details admin_calibrations].each do |report_type|
      report_export = ReportExport.new(user: users(:user_guochunzhong),
        company_evaluation: company_evaluations(:ce_one), report_type: report_type, locale: "zh-CN")
      Tempfile.create(["batch-score-report", ".xlsx"]) do |file|
        queries = capture_queries { report_export.generator.call(file.path) }
        assert_equal 1, performance_queries(queries).size, report_type
        assert_match(/GROUP BY/, performance_queries(queries).first)
      end
    end
  end

  test "detail reports skip capability names that have no evaluation column" do
    labels = Capability.profession_column_label_and_names + [["Future capability", "future_capability"]]
    with_replaced_method(Capability, :profession_column_label_and_names, -> { labels }) do
      %w[admin_evaluation_details hr_evaluation_details].each do |report_type|
        report_export = ReportExport.new(user: users(:user_guochunzhong),
          company_evaluation: company_evaluations(:ce_one), report_type: report_type, locale: "zh-CN")
        Tempfile.create(["detail-report", ".xlsx"]) do |file|
          report_export.generator.call(file.path)
          workbook = Roo::Excelx.new(file.path)
          assert_operator workbook.last_row, :>, 1
        end
      end
    end
  end

  private

  def add_performance(evaluation, weight:, score:, **attributes)
    JobRoleEvaluationPerformance.create!({user: evaluation.user,
                                          company_evaluation: evaluation.company_evaluation_template.company_evaluation,
                                          dept_code: evaluation.dept_code, st_code: evaluation.job_role.st_code,
                                          import_guid: SecureRandom.uuid, obj_name: "Export scoring regression",
                                          obj_weight_pct: weight, obj_result: score}.merge(attributes))
  end

  def capture_queries
    queries = []
    subscriber = ->(event) { queries << event.payload[:sql] unless event.payload[:name] == "SCHEMA" || event.payload[:cached] }
    ActiveRecord::Base.uncached do
      ActiveSupport::Notifications.subscribed(subscriber, "sql.active_record") { yield }
    end
    queries
  end

  def performance_queries(queries)
    queries.select { |sql| sql.match?(/SUM\(/i) && sql.include?("job_role_evaluation_performances") }
  end
end
