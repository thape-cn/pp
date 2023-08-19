class JobRolePolicy < ApplicationPolicy
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
end
