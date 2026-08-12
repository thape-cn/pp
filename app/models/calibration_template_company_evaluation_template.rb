class CalibrationTemplateCompanyEvaluationTemplate < ApplicationRecord
  belongs_to :calibration_template
  belongs_to :company_evaluation_template

  validates :calibration_template_id, uniqueness: {scope: :company_evaluation_template_id}
end
