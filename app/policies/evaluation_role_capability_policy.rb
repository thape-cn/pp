class EvaluationRoleCapabilityPolicy < ApplicationPolicy
  def update?
    user.admin?
  end
end
