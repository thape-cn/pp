require "test_helper"
require_relative "../support/report_export_helpers"

class GenerateReportExportJobTest < ActiveSupport::TestCase
  include ReportExportHelpers

  teardown { purge_report_files }

  test "generates every Excel format with its original column count" do
    column_counts = {
      "admin_evaluations" => 14, "admin_evaluation_details" => 16,
      "admin_archived_evaluations" => 16, "admin_calibrations" => 20,
      "admin_performances" => 15, "admin_users" => 18, "admin_job_roles" => 8,
      "admin_progress" => 7, "hr_evaluations" => 11, "hr_evaluation_details" => 13,
      "hr_progress" => 7, "cp_evaluations" => 11, "staff_evaluations" => 8,
      "staff_evaluation_details" => 10, "staff_progress" => 7
    }
    column_counts.each do |report_type, column_count|
      report_export = create_report_export(report_type: report_type)
      GenerateReportExportJob.new.perform(report_export.id)
      assert_predicate report_export.reload, :completed?, report_type
      assert report_export.file.attached?, report_type
      assert_in_delta 7.days, report_export.expires_at - report_export.completed_at, 1
      with_report_workbook(report_export) do |workbook|
        assert_equal column_count, workbook.row(1).size, report_type
      end
    end
  end

  test "admin detail retains comments scores and leading zero identifiers" do
    evaluation = evaluation_user_capabilities(:euc_pp4)
    evaluation.update_columns(self_overall_output: "完成年度目标并对项目成果进行全面总结说明")
    evaluation.user.update!(clerk_code: "000123")
    evaluation.job_role.update!(st_code: "000456")
    report_export = create_report_export
    GenerateReportExportJob.new.perform(report_export.id)
    with_report_workbook(report_export.reload) do |workbook|
      rows = (2..workbook.last_row).map { |row| workbook.row(row) }.select { |row| row[1] == evaluation.user_id }
      assert_operator rows.size, :>=, 9
      output_row = rows.find { |row| row[14] == I18n.t("evaluation.self_overall_output", locale: report_export.locale) }
      assert_equal evaluation.self_overall_output, output_row[15]
      assert_equal "000123", output_row[2]
      assert_equal "000456", output_row[3]
      assert_equal "000001", output_row[7]
      assert_equal evaluation.final_score_in_metric, output_row[12]
    end
  end

  test "job scopes staff data at execution time and preserves the selected locale" do
    requester = users(:user_pptest4)
    report_export = create_report_export(report_type: "staff_evaluation_details", user: requester, locale: "en")
    evaluation = evaluation_user_capabilities(:euc_pp5)
    evaluation.update_columns(manager_user_id: requester.id)
    original_locale = I18n.locale
    GenerateReportExportJob.new.perform(report_export.id)
    assert_equal original_locale, I18n.locale
    with_report_workbook(report_export.reload) do |workbook|
      assert_equal I18n.t("user.chinese_name", locale: :en), workbook.row(1).first
      names = (2..workbook.last_row).map { |row| workbook.row(row).first }.uniq
      assert_includes names, requester.chinese_name
      assert_includes names, evaluation.user.chinese_name
      assert_not_includes names, users(:user_pptest6).chinese_name
      assert_equal 6 * names.size + 1, workbook.last_row
    end
  end

  test "revoked HR permission fails without generating a file" do
    requester = users(:user_pptest4)
    company = requester.hr_user_managed_companies.create!(managed_company: "测试公司")
    report_export = create_report_export(report_type: "hr_evaluations", user: requester)
    company.destroy!
    GenerateReportExportJob.new.perform(report_export.id)
    assert_predicate report_export.reload, :failed?
    assert_not report_export.file.attached?
  end

  test "generation failures wait for automatic retry and become failed when exhausted" do
    report_export = create_report_export
    with_replaced_method(ReportExports::AdminEvaluationDetails, :new, ->(*) { raise IOError, "generation failed" }) do
      assert_raises(IOError) { GenerateReportExportJob.new.perform(report_export.id) }
    end
    assert_predicate report_export.reload, :retrying?
    assert_not report_export.file.attached?
    GenerateReportExportJob.sidekiq_retries_exhausted_block.call({"args" => [report_export.id]}, IOError.new("generation failed"))
    assert_predicate report_export.reload, :failed?
  end

  test "duplicate execution of a completed export does not regenerate its file" do
    report_export = create_report_export
    job = GenerateReportExportJob.new
    job.perform(report_export.id)
    blob_id = report_export.reload.file.blob.id
    job.perform(report_export.id)
    assert_equal blob_id, report_export.reload.file.blob.id
  end

  test "cleanup purges expired files while preserving recent downloads" do
    expired_export = create_report_export
    recent_export = create_report_export
    [expired_export, recent_export].each { |report_export| GenerateReportExportJob.new.perform(report_export.id) }
    expired_export.reload.update!(expires_at: 1.second.ago)
    PurgeExpiredReportExportsJob.new.perform
    assert_not expired_export.reload.file.attached?
    assert_predicate expired_export, :expired?
    assert_predicate recent_export.reload, :downloadable?
  end
end
