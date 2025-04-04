class CompanyEvaluationTemplate < ApplicationRecord
  belongs_to :company_evaluation
  has_many :calibration_templates
  has_many :evaluation_user_capabilities
  validates :title, :group_level, presence: true

  def self.group_level_options
    {
      I18n.t("evaluation.staff_level") => "staff",
      I18n.t("evaluation.manager_level_a") => "manager_a",
      I18n.t("evaluation.manager_level_b") => "manager_b",
      I18n.t("evaluation.auxiliary_level") => "auxiliary"
    }
  end
end
