require "test_helper"
require_relative "../support/report_export_helpers"

class ReportExportTest < ActiveSupport::TestCase
  include ReportExportHelpers

  test "validates report type locale and required evaluation" do
    report_export = ReportExport.new(user: users(:user_guochunzhong), report_type: "anything", locale: "unknown")
    assert_not report_export.valid?
    assert report_export.errors[:report_type].present?
    assert report_export.errors[:locale].present?
    report_export.assign_attributes(report_type: "admin_evaluation_details", locale: "zh-CN")
    assert_not report_export.valid?
    assert report_export.errors[:company_evaluation].present?
    report_export.report_type = "admin_users"
    assert_predicate report_export, :valid?
  end

  test "report policy preserves each namespace access rule" do
    requester = users(:user_pptest4)
    %w[admin_evaluations admin_users hr_evaluations cp_evaluations staff_progress].each do |type|
      report_export = create_report_export(report_type: type, user: requester)
      assert_not ReportExportPolicy.new(requester, report_export).create?, type
    end
    report_export = create_report_export(report_type: "staff_evaluations", user: requester)
    assert ReportExportPolicy.new(requester, report_export).create?
  end
end
