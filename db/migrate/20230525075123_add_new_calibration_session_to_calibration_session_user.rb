class AddNewCalibrationSessionToCalibrationSessionUser < ActiveRecord::Migration[7.1]
  def change
    add_reference :calibration_session_users, :new_calibration_session, null: true
  end
end
