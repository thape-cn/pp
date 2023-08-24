module HR
  class ManagerPerformancesController < BaseController
    include StaffManagerGroup

    def index
      @company_evaluation_id = params[:company_evaluation_id].presence
      company_evaluation = CompanyEvaluation.find_by(id: @company_evaluation_id) || CompanyEvaluation.last
      company_template_ids = CompanyEvaluationTemplate.where(group_level: "manager")
        .where(company_evaluation_id: company_evaluation.id).pluck(:id)
      evaluation_user_capabilities = policy_scope(EvaluationUserCapability)
        .where(company_evaluation_template_id: company_template_ids)
      @evaluation_user_capabilities_group = manager_group(evaluation_user_capabilities)
    end
  end
end
