require "application_system_test_case"
require "warden/test/helpers"
require_relative "../support/report_export_helpers"

class ReportExportsTest < ApplicationSystemTestCase
  include Warden::Test::Helpers
  include ReportExportHelpers

  setup do
    Sidekiq.testing!(:fake)
    @admin = users(:user_guochunzhong)
    @admin.update!(preferred_language: "zh-CN")
    login_as @admin, scope: :user
  end

  teardown do
    Warden.test_reset!
    GenerateReportExportJob.clear
    purge_report_files
    Sidekiq.testing!(:disable)
  end

  test "admin starts a detail export and returns later to download it" do
    visit admin_company_evaluation_user_capabilities_path(company_evaluation_id: company_evaluations(:ce_one).id, locale: "zh-CN")
    click_link "导出 Excel 明细报表"
    assert_text "排队中"
    assert_text "稍后从“我的导出”下载"
    report_export = ReportExport.order(:id).last
    assert_equal [report_export.id], GenerateReportExportJob.jobs.last["args"]

    GenerateReportExportJob.new.perform(report_export.id)
    assert_text "已完成", wait: 8
    assert_link "下载文件", href: download_report_export_path(report_export)
    click_link "我的导出", match: :first
    assert_current_path report_exports_path
    assert_text "已完成"
    assert_link "下载文件", href: download_report_export_path(report_export)
  end

  test "failed exports can be submitted again from their status page" do
    report_export = create_report_export(status: :failed)
    visit report_export_path(report_export)
    assert_text "导出失败"
    click_button "重新导出"
    assert_text "排队中"
    assert_equal 1, GenerateReportExportJob.jobs.size
  end
end
