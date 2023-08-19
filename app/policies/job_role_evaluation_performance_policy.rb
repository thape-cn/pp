class JobRoleEvaluationPerformancePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.none
      end
    end
  end

  def edit?
    user.admin?
  end

  def update?
    edit?
  end

  def new?
    user.admin?
  end

  def create?
    new?
  end

  def show?
    user.admin? || record.user_id == user.id || true
  end
end
