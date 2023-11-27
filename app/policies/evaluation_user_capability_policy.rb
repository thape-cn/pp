class EvaluationUserCapabilityPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.hr_staff?
        scope.where(company: user.hr_user_managed_companies.pluck(:managed_company))
      elsif user.hr_bp?
        scope.where(dept_code: user.hrbp_user_managed_departments.where(auto_generated: true).pluck(:managed_dept_code))
          .or(scope.where(user_id: user.id))
          .or(scope.where(manager_user_id: user.id))
      else
        session_user_ids = user.owned_calibration_sessions.collect { |cs| cs.calibration_session_users.collect(&:user_id) }.flatten
        scope.where(user_id: user.id)
          .or(scope.where(manager_user_id: user.id))
          .or(scope.where(user_id: session_user_ids))
      end
    end
  end

  def create?
    user.admin?
  end

  def show?
    return true if user.admin?

    hr_bp_managed_companies = user.hr_user_managed_companies.pluck(:managed_company)
    return true if hr_bp_managed_companies.include?(record.company)

    hrbp_user_managed_departments = user.hrbp_user_managed_departments.where(auto_generated: true).pluck(:managed_dept_code)
    return true if hrbp_user_managed_departments.include?(record.dept_code)

    record.user_id == user.id ||
      record.manager_user&.id == user.id ||
      record.calibration_session_users.any? { |csu| csu.calibration_session.owner_id == user.id } ||
      record.calibration_session_users.any? { |csv| csu.calibration_session.calibration_session_judges.any? { |csj| csj.judge_id == user.id } }
  end

  def print?
    return true if user.admin?

    hr_bp_managed_companies = user.hr_user_managed_companies.pluck(:managed_company)
    return true if hr_bp_managed_companies.include?(record.company)

    record.user_id == user.id ||
      record.manager_user&.id == user.id ||
      record.calibration_session_users.any? { |csu| csu.calibration_session.owner_id == user.id } ||
      record.calibration_session_users.any? { |csv| csu.calibration_session.calibration_session_judges.any? { |csj| csj.judge_id == user.id } }
  end

  def update?
    show?
  end

  def confirm_destroy?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  def edit?
    return true if user.admin?

    user.hr_user_managed_companies.pluck(:managed_company).include?(record.company)
  end

  def custom_description_dialog?
    custom_description?
  end

  def custom_description?
    user.admin?
  end

  def overall_text?
    if user.admin? || user.hr_staff? || user.id == record.manager_user_id
      true
    elsif record.calibration_session_users.any? { |csu| csu.calibration_session.owner_id == user.id } ||
        record.calibration_session_users.any? { |csv| csu.calibration_session.calibration_session_judges.any? { |csj| csj.judge_id == user.id } }
      true
    end
  end
end
