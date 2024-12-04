class CalibrationSessionPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(owner_id: user.id).or(scope.where(hr_reviewer_id: user.id))
          .left_joins(:calibration_session_judges)
          .or(scope.left_joins(:calibration_session_judges).where(calibration_session_judges: {judge_id: user.id}))
      end
    end
  end

  def new?
    user.admin? || user.hr_staff?
  end

  def create?
    new?
  end

  def show?
    return true if user.admin?
    record.owner_id == user.id \
    || record.hr_reviewer_id == user.id \
    || record.calibration_session_judges.collect(&:judge_id).include?(user.id)
  end

  def update?
    return true if user.admin?
    record.owner_id == user.id \
    || record.hr_reviewer_id == user.id \
    || record.calibration_session_judges.collect(&:judge_id).include?(user.id)
  end

  def finalize_calibration?
    return true if user.admin?
    record.owner_id == user.id
  end

  def approve_confirm?
    user.admin? || user.hr_staff?
  end

  def approve?
    approve_confirm?
  end

  def undo_confirm?
    user.admin? || user.hr_staff? || record.hr_reviewer_id == user.id
  end

  def undo?
    undo_confirm?
  end

  def destroy_confirm?
    user.admin?
  end

  def destroy?
    destroy_confirm?
  end

  def fixed?
    user.present?
  end

  def reconcile_session_status?
    user.admin?
  end
end
