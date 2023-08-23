class AddCompanyEvaluationToImportExcelFile < ActiveRecord::Migration[7.1]
  def change
    add_reference :import_excel_files, :company_evaluation, null: false
  end
end
