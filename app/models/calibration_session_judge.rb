class CalibrationSessionJudge < ApplicationRecord
  belongs_to :calibration_session
  belongs_to :judge, class_name: "User"
end
