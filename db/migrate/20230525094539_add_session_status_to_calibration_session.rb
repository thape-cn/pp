class AddSessionStatusToCalibrationSession < ActiveRecord::Migration[7.1]
  def change
    remove_column :calibration_sessions, :finalize, default: false, null: false
    add_column :calibration_sessions, :session_status, :string, null: false, default: "waiting_manager_score"
  end
end
