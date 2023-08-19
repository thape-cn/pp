class ArchivedEvaluationUserCapability < ApplicationRecord
  belongs_to :company_evaluation_template
  belongs_to :user
  belongs_to :job_role
  belongs_to :manager_user, optional: true, class_name: :User
  belongs_to :deleted_user, class_name: :User
  validates_presence_of :deleted_reason
end
