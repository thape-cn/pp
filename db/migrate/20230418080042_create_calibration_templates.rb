class CreateCalibrationTemplates < ActiveRecord::Migration[7.1]
  def change
    create_table :calibration_templates do |t|
      t.references :company_evaluation_template, null: false, foreign_key: true
      t.boolean :enforce_distribute, default: false, null: false
      t.integer :apa_grade_rate, default: 30, null: false
      t.integer :b_grade_rate, default: 40, null: false
      t.integer :cd_grade_rate, default: 30, null: false

      t.timestamps
    end
  end
end
