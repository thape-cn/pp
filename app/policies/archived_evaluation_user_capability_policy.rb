class ArchivedEvaluationUserCapabilityPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.hr_staff?
        scope.where(company: user.hr_user_managed_companies.pluck(:managed_company))
      elsif user.hr_bp?
        scope.where(dept_code: user.hrbp_user_managed_departments.pluck(:managed_dept_code))
      else
        scope.where(user_id: user.id)
          .or(scope.where(manager_user_id: user.id))
      end
    end
  end

  def confirm_restore?
    user.admin?
  end

  def restore?
    confirm_restore?
  end
end
