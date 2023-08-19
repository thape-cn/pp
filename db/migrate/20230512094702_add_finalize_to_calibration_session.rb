class AddFinalizeToCalibrationSession < ActiveRecord::Migration[7.1]
  def change
    add_column :calibration_sessions, :finalize, :boolean, default: false, null: false
  end
end
