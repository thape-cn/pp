class AddCalibrationManagementProfessionPerformanceScore < ActiveRecord::Migration[7.1]
  def change
    add_column :evaluation_user_capabilities, :calibration_management_profession_score, :integer
    add_column :evaluation_user_capabilities, :calibration_performance_score, :integer
  end
end
