class CreateImportExcelFiles < ActiveRecord::Migration[7.1]
  def change
    create_table :import_excel_files do |t|
      t.string :import_type, null: false
      t.string :title
      t.references :user, null: false

      t.timestamps
    end
  end
end
