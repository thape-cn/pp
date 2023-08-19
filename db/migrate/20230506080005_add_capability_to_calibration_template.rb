class AddCapabilityToCalibrationTemplate < ActiveRecord::Migration[7.1]
  def change
    add_column :calibration_templates, :below_standard_rate, :integer, default: 30, null: false
    add_column :calibration_templates, :standards_compliant_rate, :integer, default: 40, null: false
    add_column :calibration_templates, :beyond_standard_rate, :integer, default: 30, null: false
  end
end
