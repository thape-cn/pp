require "test_helper"
require_relative "../../support/report_export_helpers"

class Staff::PrintingControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ReportExportHelpers

  setup do
    @evaluation = evaluation_user_capabilities(:euc_pp6)
    sign_in @evaluation.user

    events = @browser_events = []
    pdf_data = @pdf_data = "%PDF-1.4\nreport\xFF".b
    @browser = Object.new
    @browser.define_singleton_method(:go_to) { |url| events << [:go_to, url] }
    @browser.define_singleton_method(:network) { self }
    @browser.define_singleton_method(:wait_for_idle) { events << :wait_for_idle }
    @browser.define_singleton_method(:pdf) do |encoding:|
      events << [:pdf, encoding]
      pdf_data
    end
    @browser.define_singleton_method(:quit) { events << :quit }
  end

  test "PDF is returned inline without queuing an export and preserves the selected language" do
    browser = @browser
    with_replaced_method(Ferrum::Browser, :new, ->(**) { browser }) do
      Sidekiq.testing!(:fake) do
        assert_no_difference ["ReportExport.count", "GenerateReportExportJob.jobs.size"] do
          get pdf_staff_printing_path(@evaluation, format: :pdf, locale: "en")
        end
      end
    end

    assert_response :success
    assert_equal "application/pdf", response.media_type
    assert_match(/\Ainline;/, response.headers["Content-Disposition"])
    assert_includes response.headers["Content-Disposition"], "#{@evaluation.id}_printed.pdf"
    assert_equal @pdf_data, response.body
    assert_equal [
      [:go_to, staff_printing_url(@evaluation, locale: "en")],
      :wait_for_idle, [:pdf, :binary], :quit
    ], @browser_events
  end

  test "browser closes when PDF rendering fails" do
    @browser.define_singleton_method(:pdf) { |**| raise IOError, "rendering failed" }

    browser = @browser
    with_replaced_method(Ferrum::Browser, :new, ->(**) { browser }) do
      assert_raises(IOError) do
        get pdf_staff_printing_path(@evaluation, format: :pdf)
      end
    end

    assert_equal :quit, @browser_events.last
  end

  test "unauthorized users cannot start a PDF browser" do
    sign_in users(:user_pptest4)

    with_replaced_method(Ferrum::Browser, :new, ->(**) { raise "Browser must not start before authorization" }) do
      assert_no_difference "ReportExport.count" do
        assert_raises(Pundit::NotAuthorizedError) do
          get pdf_staff_printing_path(@evaluation, format: :pdf)
        end
      end
    end
  end

  test "anonymous users must sign in before generating a PDF" do
    sign_out @evaluation.user

    with_replaced_method(Ferrum::Browser, :new, ->(**) { raise "Browser must not start before authentication" }) do
      get pdf_staff_printing_path(@evaluation, format: :pdf)
    end

    assert_response :unauthorized
  end
end
