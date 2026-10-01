require "test_helper"
Sidekiq.testing!(:fake)
require_relative "../support/report_export_helpers"

class ReportExportsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ReportExportHelpers

  setup do
    @admin = users(:user_guochunzhong)
    @evaluation = company_evaluations(:ce_one)
    sign_in @admin
  end

  teardown do
    GenerateReportExportJob.clear
    purge_report_files
  end

  test "every Excel entry point queues a job and redirects without generating a file" do
    evaluation_options = {company_evaluation_id: @evaluation.id, format: :xlsx, locale: "en"}
    routes = {
      excel_report_admin_company_evaluation_user_capabilities_path(**evaluation_options) => "admin_evaluations",
      excel_detail_report_admin_company_evaluation_user_capabilities_path(**evaluation_options) => "admin_evaluation_details",
      excel_detail_report_admin_company_evaluation_history_user_capabilities_path(**evaluation_options) => "admin_evaluation_details",
      excel_report_admin_company_evaluation_archived_user_capabilities_path(**evaluation_options) => "admin_archived_evaluations",
      excel_report_admin_company_evaluation_user_calibrations_path(**evaluation_options) => "admin_calibrations",
      excel_report_admin_company_evaluation_performances_path(**evaluation_options) => "admin_performances",
      excel_report_admin_users_path(format: :xlsx, locale: "en") => "admin_users",
      excel_report_admin_job_roles_path(format: :xlsx, locale: "en") => "admin_job_roles",
      admin_root_path(format: :xlsx, locale: "en") => "admin_progress",
      excel_report_hr_company_evaluation_user_capabilities_path(**evaluation_options) => "hr_evaluations",
      excel_detail_report_hr_company_evaluation_user_capabilities_path(**evaluation_options) => "hr_evaluation_details",
      hr_root_path(format: :xlsx, locale: "en") => "hr_progress",
      excel_report_cp_company_evaluation_user_capabilities_path(**evaluation_options) => "cp_evaluations",
      excel_report_staff_company_evaluation_user_capabilities_path(**evaluation_options) => "staff_evaluations",
      excel_detail_report_staff_company_evaluation_user_capabilities_path(**evaluation_options) => "staff_evaluation_details",
      staff_evaluation_progress_path(format: :xlsx, locale: "en") => "staff_progress"
    }

    Sidekiq.testing!(:fake) do
      routes.each do |path, report_type|
        assert_difference ["ReportExport.count", "GenerateReportExportJob.jobs.size"], 1 do
          get path
        end
        report_export = ReportExport.order(:id).last
        assert_redirected_to report_export_path(report_export, format: :html)
        assert_response :see_other
        assert_equal report_type, report_export.report_type
        assert_equal @admin.id, report_export.user_id
        assert_equal "en", report_export.locale
        assert_predicate report_export, :queued?
        assert_not report_export.file.attached?
        assert_equal [report_export.id], GenerateReportExportJob.jobs.last["args"]
        assert_equal "reports", GenerateReportExportJob.jobs.last["queue"]
      end
    end
  end

  test "PDF export is queued with an authorized printing URL" do
    Sidekiq.testing!(:fake) do
      get pdf_staff_printing_path(evaluation_user_capabilities(:euc_one), format: :pdf)
      report_export = ReportExport.order(:id).last
      assert_redirected_to report_export_path(report_export, format: :html)
      assert_equal "staff_printing", report_export.report_type
      assert_equal evaluation_user_capabilities(:euc_one).id, report_export.options["evaluation_user_capability_id"]
      assert_includes report_export.options["printing_url"], "/staff/printing/"
      assert_not report_export.file.attached?
    end
  end

  test "requester can view progress and download the completed workbook" do
    report_export = create_report_export
    get report_export_path(report_export)
    assert_response :success
    assert_select 'meta[http-equiv="refresh"][content="5"]'
    assert_select "a[href='#{download_report_export_path(report_export)}']", count: 0

    GenerateReportExportJob.new.perform(report_export.id)
    get report_export_path(report_export)
    assert_response :success
    assert_select 'meta[http-equiv="refresh"]', count: 0
    assert_select "a[href='#{download_report_export_path(report_export)}']"

    get download_report_export_path(report_export)
    assert_response :success
    assert_equal "no-store", response.headers["Cache-Control"]
    assert_includes response.headers["Content-Disposition"], "attachment"
    assert_includes response.headers["Content-Disposition"], "_detail.xlsx"
    assert_equal report_export.reload.file.download, response.body
  end

  test "other users cannot list view download or retry an export" do
    report_export = create_report_export(status: :failed)
    sign_in users(:user_pptest4)
    get report_exports_path
    assert_response :success
    assert_select "a[href='#{report_export_path(report_export)}']", count: 0

    get report_export_path(report_export)
    assert_response :not_found
    get download_report_export_path(report_export)
    assert_response :not_found
    post retry_report_export_path(report_export)
    assert_response :not_found
  end

  test "pending and expired files cannot be downloaded" do
    report_export = create_report_export
    get download_report_export_path(report_export)
    assert_redirected_to report_export_path(report_export)

    GenerateReportExportJob.new.perform(report_export.id)
    travel_to 8.days.from_now do
      get download_report_export_path(report_export)
      assert_redirected_to report_export_path(report_export)
      get report_export_path(report_export)
      assert_select "a[href='#{download_report_export_path(report_export)}']", count: 0
    end
  end

  test "a failed export can be retried and the request language is preserved" do
    report_export = create_report_export(status: :failed, locale: "en")
    Sidekiq.testing!(:fake) do
      assert_difference ["ReportExport.count", "GenerateReportExportJob.jobs.size"], 1 do
        post retry_report_export_path(report_export)
      end
    end
    retried_export = ReportExport.order(:id).last
    assert_redirected_to report_export_path(retried_export)
    assert_equal "en", retried_export.locale
    assert_predicate retried_export, :queued?
    assert_predicate report_export.reload, :failed?
  end

  test "queue connection failure shows a failed export that can be retried" do
    with_replaced_method(GenerateReportExportJob, :perform_async, ->(*) { raise IOError, "queue unavailable" }) do
      get excel_detail_report_admin_company_evaluation_user_capabilities_path(company_evaluation_id: @evaluation.id, format: :xlsx)
    end
    report_export = ReportExport.order(:id).last
    assert_predicate report_export, :failed?
    follow_redirect!
    assert_response :success
    assert_select "form[action='#{retry_report_export_path(report_export)}']"
  end

  test "staff cannot enqueue an admin export" do
    sign_in users(:user_pptest4)
    assert_no_difference "ReportExport.count" do
      get excel_detail_report_admin_company_evaluation_user_capabilities_path(company_evaluation_id: @evaluation.id, format: :xlsx)
    end
    assert_redirected_to root_url
  end

  test "anonymous users must sign in to access exports" do
    sign_out @admin
    get report_exports_path
    assert_redirected_to new_user_session_path
  end
end
