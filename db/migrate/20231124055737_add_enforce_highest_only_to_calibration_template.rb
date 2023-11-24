class AddEnforceHighestOnlyToCalibrationTemplate < ActiveRecord::Migration[7.1]
  def change
    add_column :calibration_templates, :enforce_highest_only, :boolean, null: false, default: false
  end
end
