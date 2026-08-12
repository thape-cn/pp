class CalibrationSessionUser < ApplicationRecord
  belongs_to :calibration_session
  belongs_to :new_calibration_session, class_name: "CalibrationSession", optional: true
  belongs_to :user
  belongs_to :evaluation_user_capability
  validate :calibration_template_belongs_to_users_company_evaluation

  private

  def calibration_template_belongs_to_users_company_evaluation
    calibration_template = calibration_session&.calibration_template
    company_evaluation_template = evaluation_user_capability&.company_evaluation_template
    return if calibration_template.blank? || company_evaluation_template.blank?
    return if calibration_template.company_evaluation_id == company_evaluation_template.company_evaluation_id

    errors.add(:calibration_session, "must use a calibration template from the user's company evaluation")
  end
end
