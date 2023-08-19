class AddCalibrationWorkToEvaluationUserCapability < ActiveRecord::Migration[7.1]
  def change
    add_column :evaluation_user_capabilities, :calibration_work_load, :integer
    add_column :evaluation_user_capabilities, :calibration_work_attitude, :integer
    add_column :evaluation_user_capabilities, :calibration_work_quality, :integer
  end
end
