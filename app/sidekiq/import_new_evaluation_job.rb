class ImportNewEvaluationJob
  include Sidekiq::Job

  def perform(import_excel_file_id)
    import_excel_file = ImportExcelFile.find(import_excel_file_id)
    Rails.logger.info "Start importing new evaluation job, import_excel_file_id: #{import_excel_file_id}"
    InitiationNewEvaluation.do_validate_euc(import_excel_file)
    Rails.logger.info "End importing new evaluation job, import_excel_file_id: #{import_excel_file_id}"
  end
end
