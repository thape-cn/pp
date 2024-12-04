class CalibrationSessionUserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(user_id: user.id)
      end
    end
  end

  def confirm_destroy?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  def undo_confirm?
    user.admin? || user.hr_staff? || record.calibration_session.hr_reviewer_id == user.id
  end

  def undo?
    undo_confirm?
  end
end
