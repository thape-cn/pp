class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        return scope.includes(:user_job_roles)
      end

      base_scope = scope.includes(:user_job_roles)
      scopes = [base_scope.where(id: user.id)]

      if user.corp_president?
        scopes << base_scope.where(user_job_roles: {company: user.corp_president_managed_companies.collect(&:managed_company)})
      else
        if user.hr_staff?
          scopes << base_scope.where(user_job_roles: {company: user.hr_user_managed_companies.collect(&:managed_company)})
        end

        if user.hr_bp?
          scopes << base_scope.where(user_job_roles: {dept_code: user.hrbp_user_managed_departments.pluck(:managed_dept_code)})
        end

        if user.secretary?
          scopes << base_scope.where(user_job_roles: {dept_code: user.secretary_managed_departments.pluck(:managed_dept_code)})
        end
      end

      return scopes.compact.reduce { |combined_scope, s| combined_scope.or(s) } if scopes.size > 1

      scopes.first
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
