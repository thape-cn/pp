class CompanyEvaluationTemplate < ApplicationRecord
  belongs_to :company_evaluation
  has_many :calibration_templates
  has_many :evaluation_user_capabilities

  def self.group_level_options
    {
      I18n.t("evaluation.staff_level") => "staff",
      I18n.t("evaluation.manager_level") => "manager"
    }
  end
end
