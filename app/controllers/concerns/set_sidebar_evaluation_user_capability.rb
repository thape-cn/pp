module SetSidebarEvaluationUserCapability
  extend ActiveSupport::Concern

  private

  def set_sidebar_evaluation_user_capabilities
    @company_evaluations = CompanyEvaluation.open_for_user
  end
end
