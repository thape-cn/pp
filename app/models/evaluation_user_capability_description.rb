class EvaluationUserCapabilityDescription < ApplicationRecord
  belongs_to :company_evaluation_template
  belongs_to :user
  belongs_to :capability
end
