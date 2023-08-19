class AddEvaluationUserCapabilityToCalibrationSessionUser < ActiveRecord::Migration[7.1]
  def change
    add_reference :calibration_session_users, :evaluation_user_capability, null: false, foreign_key: false
  end
end
