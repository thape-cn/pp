class CompanyEvaluationTemplatePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.none
      end
    end
  end

  def new?
    user.admin?
  end

  def create?
    new?
  end

  def edit?
    user.admin?
  end

  def update?
    edit?
  end

  def confirm_destroy?
    user.admin?
  end

  def destroy?
    confirm_destroy?
  end
end
