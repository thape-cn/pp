module Admin
  class UserDescriptionsController < BaseController
    after_action :verify_policy_scoped, only: %i[index]

    def index
      @company_evaluation = CompanyEvaluation.find params[:company_evaluation_id]
      @evaluation_user_capability_descriptions = policy_scope(EvaluationUserCapabilityDescription)
        .where(company_evaluation_template_id: @company_evaluation.company_evaluation_templates.pluck(:id))
    end
  end
end
