class PurgeExpiredReportExportsJob
  include Sidekiq::Job

  def perform
    ReportExport.joins(:file_attachment).where(expires_at: ..Time.current).find_each do |report_export|
      report_export.file.purge
    end
  end
end
