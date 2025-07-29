class EvaluationUserCapabilityPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.corp_president?
        managed_company_user_ids = UserJobRole.where(is_active: true)
          .where(company: user.corp_president_managed_companies.pluck(:managed_company))
          .pluck(:user_id)
        all_related_user_ids = (calibration_related_user_ids + managed_company_user_ids + [user.id]).uniq

        scope.where(company: user.corp_president_managed_companies.pluck(:managed_company))
          .or(scope.where(manager_user_id: user.id))
          .or(scope.where(user_id: all_related_user_ids))
      elsif user.hr_staff? && user.hr_bp?
        managed_company_user_ids = UserJobRole.where(is_active: true)
          .where(company: user.hr_user_managed_companies.pluck(:managed_company))
          .pluck(:user_id)
        all_related_user_ids = (calibration_related_user_ids + managed_company_user_ids + [user.id]).uniq

        hr_staff_scope = scope.where(company: user.hr_user_managed_companies.pluck(:managed_company))
        hr_bp_scope = scope.where(dept_code: user.hrbp_user_managed_departments.pluck(:managed_dept_code))

        hr_staff_scope.or(hr_bp_scope)
          .or(scope.where(manager_user_id: user.id))
          .or(scope.where(user_id: all_related_user_ids))
      elsif user.hr_staff? && user.secretary?
        managed_company_user_ids = UserJobRole.where(is_active: true)
          .where(company: user.hr_user_managed_companies.pluck(:managed_company))
          .pluck(:user_id)
        all_related_user_ids = (calibration_related_user_ids + managed_company_user_ids + [user.id]).uniq

        hr_staff_scope = scope.where(company: user.hr_user_managed_companies.pluck(:managed_company))
          .or(scope.where(manager_user_id: user.id))
          .or(scope.where(user_id: all_related_user_ids))

        secretary_scope = scope.where(dept_code: user.secretary_managed_departments.pluck(:managed_dept_code))

        hr_staff_scope.or(secretary_scope)
      elsif user.hr_staff?
        managed_company_user_ids = UserJobRole.where(is_active: true)
          .where(company: user.hr_user_managed_companies.pluck(:managed_company))
          .pluck(:user_id)
        all_related_user_ids = (calibration_related_user_ids + managed_company_user_ids + [user.id]).uniq

        scope.where(company: user.hr_user_managed_companies.pluck(:managed_company))
          .or(scope.where(manager_user_id: user.id))
          .or(scope.where(user_id: all_related_user_ids))
      elsif user.secretary?
        scope.where(dept_code: user.secretary_managed_departments.pluck(:managed_dept_code))
          .or(scope.where(user_id: user.id))
          .or(scope.where(manager_user_id: user.id))
      elsif user.hr_bp?
        all_related_user_ids = (calibration_related_user_ids + [user.id]).uniq
        scope.where(dept_code: user.hrbp_user_managed_departments.pluck(:managed_dept_code))
          .or(scope.where(manager_user_id: user.id))
          .or(scope.where(user_id: all_related_user_ids))
      else
        all_related_user_ids = (calibration_related_user_ids + [user.id]).uniq
        scope.where(user_id: all_related_user_ids)
          .or(scope.where(manager_user_id: user.id))
      end
    end

    private

    def calibration_related_user_ids
      owned_user_ids = user.owned_calibration_sessions
        .includes(:calibration_session_users)
        .where(calibration_template_id: CalibrationTemplate.open_for_user_calibration_template_ids)
        .collect { |cs| cs.calibration_session_users.collect(&:user_id) }.flatten
      hr_reviewed_user_ids = user.hr_reviewed_calibration_sessions
        .includes(:calibration_session_users)
        .where(calibration_template_id: CalibrationTemplate.open_for_user_calibration_template_ids)
        .collect { |cs| cs.calibration_session_users.collect(&:user_id) }.flatten
      judge_user_ids = user.calibration_session_judges
        .includes(calibration_session: :calibration_session_users)
        .where(calibration_session: {calibration_template_id: CalibrationTemplate.open_for_user_calibration_template_ids})
        .collect { |csj| csj.calibration_session.calibration_session_users.collect(&:user_id) }.flatten
      (owned_user_ids + hr_reviewed_user_ids + judge_user_ids).uniq
    end
  end

  def create?
    user.admin?
  end

  def show?
    return true if user.admin?

    cp_managed_company_user_ids = UserJobRole.where(is_active: true).where(company: user.corp_president_managed_companies.pluck(:managed_company)).pluck(:user_id)
    return true if cp_managed_company_user_ids.include?(record.user_id)

    hr_managed_company_user_ids = UserJobRole.where(is_active: true).where(company: user.hr_user_managed_companies.pluck(:managed_company)).pluck(:user_id)
    return true if hr_managed_company_user_ids.include?(record.user_id)

    hrbp_user_managed_departments = user.hrbp_user_managed_departments.pluck(:managed_dept_code)
    return true if hrbp_user_managed_departments.include?(record.dept_code)

    record.user_id == user.id ||
      record.manager_user&.id == user.id ||
      record.calibration_session_users.any? { |csu| csu.calibration_session.owner_id == user.id } ||
      record.calibration_session_users.any? { |csu| csu.calibration_session.hr_reviewer_id == user.id } ||
      record.calibration_session_users.any? { |csu| csu.calibration_session.calibration_session_judges.any? { |csj| csj.judge_id == user.id } }
  end

  def print?
    return true if user.admin?

    hr_managed_company_user_ids = UserJobRole.where(is_active: true).where(company: user.hr_user_managed_companies.pluck(:managed_company)).pluck(:user_id)
    return true if hr_managed_company_user_ids.include?(record.user_id)

    hrbp_user_managed_departments = user.hrbp_user_managed_departments.pluck(:managed_dept_code)
    return true if hrbp_user_managed_departments.include?(record.dept_code)

    record.user_id == user.id ||
      record.manager_user&.id == user.id ||
      record.calibration_session_users.any? { |csu| csu.calibration_session.owner_id == user.id } ||
      record.calibration_session_users.any? { |csu| csu.calibration_session.hr_reviewer_id == user.id } ||
      record.calibration_session_users.any? { |csu| csu.calibration_session.calibration_session_judges.any? { |csj| csj.judge_id == user.id } }
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
    if user.admin? || user.hr_staff? || user.corp_president? || user.id == record.manager_user_id
      true
    elsif record.calibration_session_users.any? { |csu| csu.calibration_session.owner_id == user.id } ||
        record.calibration_session_users.any? { |csu| csu.calibration_session.hr_reviewer_id == user.id } ||
        record.calibration_session_users.any? { |csu| csu.calibration_session.calibration_session_judges.any? { |csj| csj.judge_id == user.id } }
      true
    end
  end
end
