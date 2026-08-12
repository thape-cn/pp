class CalibrationTemplateCompanyEvaluationTemplate < ApplicationRecord
  belongs_to :calibration_template
  belongs_to :company_evaluation_template

  validates :calibration_template_id, uniqueness: {scope: :company_evaluation_template_id}
  validate :templates_belong_to_same_company_evaluation

  private

  def templates_belong_to_same_company_evaluation
    return if calibration_template.blank? || company_evaluation_template.blank?
    return if calibration_template.company_evaluation_id == company_evaluation_template.company_evaluation_id

    errors.add(:company_evaluation_template, "must belong to the calibration template's company evaluation")
  end
end
