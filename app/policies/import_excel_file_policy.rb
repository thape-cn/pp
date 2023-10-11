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
    user.admin? && record.file_status != "imported"
  end

  def destroy_confirm?
    destroy?
  end

  def do_import?
    user.admin? && record.file_status == "validated"
  end

  def do_import_confirm?
    do_import?
  end
end
