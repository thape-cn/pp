module Staff
  class UserCapabilitiesController < BaseController
    include MetricHelper
    include Pagy::Method
    include SetSidebarEvaluationUserCapability

    before_action :set_sidebar_evaluation_user_capabilities, only: %i[index]
    after_action :verify_policy_scoped, only: %i[index excel_report excel_detail_report]

    def index
      @company_evaluation = CompanyEvaluation.find params[:company_evaluation_id]
      @user_id = params[:user_id]
      @manager_user_id = params[:manager_user_id]
      @form_status = params[:form_status]
      @sort_on_final_total_evaluation_score = params[:sort_on_final_total_evaluation_score] == "true"
      evaluation_user_capabilities = policy_scope(EvaluationUserCapability)
        .joins(:company_evaluation_template)
        .includes(:user, :job_role, :manager_user)
        .where(company_evaluation_template: {company_evaluation_id: @company_evaluation.id})
      if @user_id.present?
        evaluation_user_capabilities = evaluation_user_capabilities.where(user_id: @user_id)
      end
      if @manager_user_id.present?
        evaluation_user_capabilities = evaluation_user_capabilities.where(manager_user_id: @manager_user_id)
      end
      evaluation_user_capabilities = evaluation_user_capabilities.where(form_status: @form_status) if @form_status.present?
      evaluation_user_capabilities = evaluation_user_capabilities.order(final_total_evaluation_score: :asc) if @sort_on_final_total_evaluation_score.present?
      @pagy, @evaluation_user_capabilities = pagy(:offset, evaluation_user_capabilities, limit: current_user.preferred_page_length)
    end

    def excel_report
      enqueue_report_export("staff_evaluations")
    end

    def excel_detail_report
      enqueue_report_export("staff_evaluation_details")
    end
  end
end
