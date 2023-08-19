class JobRole < ApplicationRecord
  has_many :user_job_roles, dependent: :destroy
  has_many :users, through: :user_job_roles
  belongs_to :evaluation_role, optional: true
  has_many :evaluation_user_capabilities
end
