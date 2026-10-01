class CreateReportExports < ActiveRecord::Migration[8.1]
  def change
    create_table :report_exports do |t|
      t.references :user, null: false, foreign_key: true
      t.references :company_evaluation, foreign_key: true
      t.string :report_type, null: false
      t.string :locale, null: false
      t.string :status, null: false, default: "queued"
      t.json :options, null: false
      t.datetime :completed_at
      t.datetime :expires_at
      t.timestamps
    end
    add_index :report_exports, [:user_id, :created_at]
    add_index :report_exports, :expires_at
  end
end
