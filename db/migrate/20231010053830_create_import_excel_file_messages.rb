class CreateImportExcelFileMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :import_excel_file_messages do |t|
      t.string :message
      t.references :import_excel_file, null: false, foreign_key: true

      t.timestamps
    end
  end
end
