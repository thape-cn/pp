class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.includes(:user_job_roles)
      elsif user.corp_president?
        scope.includes(:user_job_roles).where(user_job_roles: {company: user.corp_president_managed_companies.collect(&:managed_company)})
          .or(scope.where(id: user.id))
      elsif user.hr_staff? && user.hr_bp?
        scope.includes(:user_job_roles)
          .where(user_job_roles: {company: user.hr_user_managed_companies.collect(&:managed_company)})
          .or(
               scope.includes(:user_job_roles).where(user_job_roles: {dept_code: user.hrbp_user_managed_departments.pluck(:managed_dept_code)})
             )
          .or(scope.where(id: user.id))
      elsif user.hr_staff?
        scope.includes(:user_job_roles).where(user_job_roles: {company: user.hr_user_managed_companies.collect(&:managed_company)})
          .or(scope.where(id: user.id))
      elsif user.secretary?
        scope.includes(:user_job_roles).where(user_job_roles: {dept_code: user.secretary_managed_departments.pluck(:managed_dept_code)})
          .or(scope.where(id: user.id))
      elsif user.hr_bp?
        scope.includes(:user_job_roles).where(user_job_roles: {dept_code: user.hrbp_user_managed_departments.pluck(:managed_dept_code)})
          .or(scope.where(id: user.id))
      else
        scope.where(id: user.id)
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
    user.admin? || record.id == user.id
  end

  def update?
    edit?
  end

  def impersonation?
    user.admin?
  end

  def sign_in_as?
    impersonation?
  end

  def change_manager_confirm?
    change_manager?
  end

  def change_manager?
    user.admin?
  end

  def new_evaluation?
    user.admin?
  end

  def show_mark_scores?
    user.admin? || EvaluationUserCapability.where(manager_user_id: user.id).present?
  end

  def mark_scores?
    show_mark_scores?
  end

  def score_confirm?
    show_mark_scores?
  end
end
