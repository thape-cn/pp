class AddHRReviewerToCalibrationSession < ActiveRecord::Migration[8.0]
  def change
    add_reference :calibration_sessions, :hr_reviewer
  end
end
