require "test_helper"
require_relative "../../support/report_export_helpers"

class ReportExports::PrintedEvaluationTest < ActiveSupport::TestCase
  include ReportExportHelpers

  teardown { purge_report_files }

  test "PDF worker writes an attachment and closes the browser" do
    report_export = create_report_export(report_type: "staff_printing", options: {
      evaluation_user_capability_id: evaluation_user_capabilities(:euc_one).id,
      printing_url: "http://example.com/staff/printing/1?locale=zh-CN"
    })
    visited_urls = []
    closed = false
    browser = Object.new
    browser.define_singleton_method(:go_to) { |url| visited_urls << url }
    browser.define_singleton_method(:network) { self }
    browser.define_singleton_method(:wait_for_idle) { true }
    browser.define_singleton_method(:pdf) { |path:| File.binwrite(path, "%PDF-1.4\nreport") }
    browser.define_singleton_method(:quit) { closed = true }

    with_replaced_method(Ferrum::Browser, :new, ->(**) { browser }) do
      GenerateReportExportJob.new.perform(report_export.id)
    end
    assert_equal [report_export.options["printing_url"]], visited_urls
    assert closed
    assert_predicate report_export.reload, :completed?
    assert_equal "application/pdf", report_export.file.content_type
    assert_equal "%PDF-1.4\nreport", report_export.file.download
  end

  test "browser is closed when printing fails" do
    report_export = create_report_export(report_type: "staff_printing", options: {printing_url: "http://example.com/"})
    closed = false
    browser = Object.new
    browser.define_singleton_method(:go_to) { |url| raise IOError, "navigation failed" }
    browser.define_singleton_method(:quit) { closed = true }
    with_replaced_method(Ferrum::Browser, :new, ->(**) { browser }) do
      assert_raises(IOError) { report_export.generator.call("unused.pdf") }
    end
    assert closed
  end

  test "PDF cannot be generated after the requester loses access to the evaluation" do
    report_export = create_report_export(report_type: "staff_printing", user: users(:user_pptest4), options: {
      evaluation_user_capability_id: evaluation_user_capabilities(:euc_pp6).id
    })
    GenerateReportExportJob.new.perform(report_export.id)
    assert_predicate report_export.reload, :failed?
    assert_not report_export.file.attached?
  end
end
