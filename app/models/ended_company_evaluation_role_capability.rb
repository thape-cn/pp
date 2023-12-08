class EndedCompanyEvaluationRoleCapability < ApplicationRecord
  belongs_to :company_evaluation
  belongs_to :evaluation_role
  belongs_to :capability
end
