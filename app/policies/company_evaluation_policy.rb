class CompanyEvaluationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin? || user.hr_staff? || user.hrbp_user_managed_departments.present?
        scope.all
      else
        scope.open_for_user
      end
    end
  end

  def index?
    user.admin?
  end

  def new?
    user.admin?
  end

  def create?
    new?
  end

  def edit?
    user.admin?
  end

  def update?
    edit?
  end

  def confirm_remove_leaving_employee_eucs?
    user.admin?
  end

  def remove_leaving_employee_eucs?
    confirm_remove_leaving_employee_eucs?
  end

  def confirm_to_end_evaluation?
    user.admin?
  end

  def to_end_evaluation?
    confirm_to_end_evaluation?
  end

  def confirm_destroy?
    user.admin?
  end

  def destroy?
    confirm_destroy?
  end

  def confirm_restore?
    user.admin?
  end

  def restore?
    confirm_restore?
  end

  def show?
    user.present?
  end

  def excel_report?
    user.admin?
  end

  def excel_detail_report?
    user.admin?
  end

  def sent_hr_review_completed_confirm?
    user.admin?
  end

  def sent_hr_review_completed_remind?
    sent_hr_review_completed_confirm?
  end

  def sent_self_assessment_confirm?
    user.admin?
  end

  def sent_self_assessment_remind?
    sent_self_assessment_confirm?
  end

  def custom_description_dialog?
    user.admin?
  end

  def custom_description?
    custom_description_dialog?
  end
end
