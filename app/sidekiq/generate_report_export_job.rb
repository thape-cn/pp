class GenerateReportExportJob
  include Sidekiq::Job

  sidekiq_options queue: "reports", retry: 3

  sidekiq_retries_exhausted do |job, error|
    ReportExport.where(id: job["args"].first).where.not(status: :completed).update_all(status: :failed, updated_at: Time.current)
    Rails.logger.error("Report export #{job["args"].first} failed: #{error.class}: #{error.message}")
  end

  def perform(report_export_id)
    report_export = ReportExport.find_by(id: report_export_id)
    return if report_export.nil? || report_export.completed?

    Pundit.authorize(report_export.user, report_export, :create?)
    report_export.update!(status: :processing)
    I18n.with_locale(report_export.locale) do
      Tempfile.create(["report-export-#{report_export.id}", ".tmp"]) do |output|
        filename = report_export.generator.call(output.path)
        content_type = if filename.end_with?(".pdf")
          "application/pdf"
        else
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        end
        output.rewind
        report_export.file.attach(io: output, filename: filename, content_type: content_type, identify: false)
      end
    end
    report_export.update!(status: :completed, completed_at: Time.current, expires_at: 7.days.from_now)
  rescue Pundit::NotAuthorizedError
    report_export.update!(status: :failed)
  rescue => error
    report_export&.update!(status: :retrying)
    Rails.logger.error("Report export #{report_export_id} will retry: #{error.class}: #{error.message}")
    raise
  end
end
