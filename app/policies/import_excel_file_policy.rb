class ImportExcelFilePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.none
      end
    end
  end

  def show?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  def destroy_confirm?
    destroy?
  end
end
