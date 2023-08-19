class CalibrationSessionUser < ApplicationRecord
  belongs_to :calibration_session
  belongs_to :new_calibration_session, class_name: "CalibrationSession", optional: true
  belongs_to :user
  belongs_to :evaluation_user_capability
end
