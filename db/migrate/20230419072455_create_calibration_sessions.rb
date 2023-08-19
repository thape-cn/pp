class CreateCalibrationSessions < ActiveRecord::Migration[7.1]
  def change
    add_column :calibration_templates, :template_name, :string, null: true
    create_table :calibration_sessions do |t|
      t.string :session_name
      t.references :calibration_template, null: false, foreign_key: true
      t.references :owner, null: false, foreign_key: false

      t.timestamps
    end
  end
end
