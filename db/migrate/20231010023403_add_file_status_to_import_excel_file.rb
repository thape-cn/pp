class AddFileStatusToImportExcelFile < ActiveRecord::Migration[7.1]
  def change
    add_column :import_excel_files, :file_status, :string, default: "do_validating", null: false
  end
end
