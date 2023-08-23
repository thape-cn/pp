class ImportNewEvaluationJob
  include Sidekiq::Job

  def perform(import_excel_file_id)
    import_excel_file = ImportExcelFile.find(import_excel_file_id)
    Rails.logger.info "Start importing new evaluation job, import_excel_file_id: #{import_excel_file_id}"
    InitiationNewEvaluation.do_import(import_excel_file.company_evaluation, import_excel_file.excel_file)
    Rails.logger.info "End importing new evaluation job, import_excel_file_id: #{import_excel_file_id}"
  end
end