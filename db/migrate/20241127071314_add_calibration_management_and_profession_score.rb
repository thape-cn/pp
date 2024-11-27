class AddCalibrationManagementAndProfessionScore < ActiveRecord::Migration[8.0]
  def change
    add_column :evaluation_user_capabilities, :calibration_management_score, :integer
    add_column :archived_evaluation_user_capabilities, :calibration_management_score, :integer
    add_column :evaluation_user_capabilities, :calibration_profession_score, :integer
    add_column :archived_evaluation_user_capabilities, :calibration_profession_score, :integer
  end
end
