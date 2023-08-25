module HR
  class StaffPerformancesController < BaseController
    include StaffManagerGroup

    def index
      @company_evaluation_id = params[:company_evaluation_id].presence
      @department = params[:department].presence
      company_evaluation = CompanyEvaluation.find_by(id: @company_evaluation_id) || CompanyEvaluation.last
      company_template_ids = CompanyEvaluationTemplate.where(group_level: "staff")
        .where(company_evaluation_id: company_evaluation.id).pluck(:id)
      evaluation_user_capabilities = policy_scope(EvaluationUserCapability)
        .where(company_evaluation_template_id: company_template_ids)
      @companies = evaluation_user_capabilities.select(:company).distinct.pluck(:company)
      @company = params[:company].presence || @companies.first
      evaluation_user_capabilities = evaluation_user_capabilities.where(company: @company)
      @departments = evaluation_user_capabilities.select(:department).distinct.pluck(:department)
      evaluation_user_capabilities = evaluation_user_capabilities.where(department: @department) if @department.present?
      @evaluation_user_capabilities_group = staff_group(evaluation_user_capabilities)
    end
  end
end
