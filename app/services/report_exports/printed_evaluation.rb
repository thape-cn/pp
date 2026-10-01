module ReportExports
  class PrintedEvaluation < Base
    def call(output_path)
      browser = Ferrum::Browser.new(process_timeout: 30)
      browser.go_to report_export.options.fetch("printing_url")
      browser.network.wait_for_idle
      browser.pdf(path: output_path)
      "#{report_export.options.fetch("evaluation_user_capability_id")}_printed.pdf"
    ensure
      browser&.quit
    end
  end
end
