class AddRowNumberToImportExcelFileMessage < ActiveRecord::Migration[7.1]
  def change
    add_column :import_excel_file_messages, :row_number, :integer
  end
end
