class CreateCalibrationSessionSaveLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :calibration_session_save_logs do |t|
      t.references :calibration_session, null: false, foreign_key: true
      t.references :saved_by, null: false, foreign_key: {to_table: :users}
      t.datetime :saved_at, null: false
      t.string :group_level, null: false
      t.string :source, null: false
      t.json :scores_snapshot, null: false

      t.timestamps
    end

    add_index :calibration_session_save_logs, :saved_at
  end
end
