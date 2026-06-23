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
    return false if record.hidden_in_staff_review_for?(user)

    true
  end
end
