module HR
  class StaffPerformancesController < BaseController
    include StaffManagerGroup
    after_action :verify_authorized, only: :show

    def index
      @company_evaluation_id = params[:company_evaluation_id].presence
      @department = params[:department].presence
      @manager_user_id = params[:manager_user_id].presence
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
      evaluation_user_capabilities = evaluation_user_capabilities.where(manager_user_id: @manager_user_id) if @manager_user_id.present?
      @evaluation_user_capabilities_group = staff_group(evaluation_user_capabilities)
      @total_people_num = @evaluation_user_capabilities_group.values.reduce(0) { |sum, array| sum + array.length }
    end

    def show
      @evaluation_user_capability = authorize policy_scope(EvaluationUserCapability).find(params[:id])
      @job_role_performances = JobRoleEvaluationPerformance.performance_from_evaluation_user_capability(@evaluation_user_capability)
      render layout: false
    end

    def more_people
      @expanded = params[:expanded] == "true"
      @department = params[:department].presence
      company_evaluation = CompanyEvaluation.find_by(id: params[:company_evaluation_id]) || CompanyEvaluation.last
      company_template_ids = CompanyEvaluationTemplate.where(group_level: "staff")
        .where(company_evaluation_id: company_evaluation.id).pluck(:id)
      evaluation_user_capabilities = policy_scope(EvaluationUserCapability)
        .where(company_evaluation_template_id: company_template_ids)
      @companies = evaluation_user_capabilities.select(:company).distinct.pluck(:company)
      @company = params[:company].presence || @companies.first
      evaluation_user_capabilities = evaluation_user_capabilities.where(company: @company)
      evaluation_user_capabilities = evaluation_user_capabilities.where(department: @department) if @department.present?
      @evaluation_user_capabilities = if @expanded
        staff_group(evaluation_user_capabilities).fetch(params[:id], []).take(EvaluationUserCapability::MINIMAL_DISPLAY_PEOPLE_NUM)
      else
        staff_group(evaluation_user_capabilities).fetch(params[:id], [])
      end
      render layout: false
    end
  end
end
