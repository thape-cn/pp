module SetSidebarEvaluationUserCapability
  extend ActiveSupport::Concern

  private

  def set_sidebar_evaluation_user_capabilities
    @company_evaluations = CompanyEvaluation.open_for_user
    @sidebar_evaluation_user_capabilities = policy_scope(EvaluationUserCapability).where(user_id: current_user.id)
      .or(policy_scope(EvaluationUserCapability).where(manager_user_id: current_user.id))
      .joins(:company_evaluation_template)
      .includes(:user, :job_role, :manager_user)
      .where(company_evaluation_template: {company_evaluation_id: @company_evaluations.pluck(:id)})
  end
end
