class ImportNewPerformanceJob
  include Sidekiq::Job

  def perform(import_excel_file_id)
    import_excel_file = ImportExcelFile.find(import_excel_file_id)
    Rails.logger.info "Start importing new performance job, import_excel_file_id: #{import_excel_file_id}"
    InitiationNewPerformance.do_validate_jrep(import_excel_file)
    Rails.logger.info "End importing new performance job, import_excel_file_id: #{import_excel_file_id}"
  end
end
