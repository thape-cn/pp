module Admin
  class HistoryUserCapabilitiesController < BaseController
    include MetricHelper
    include Pagy::Backend
    include ExcelDetailReport
    after_action :verify_policy_scoped, only: %i[index]
    before_action :set_breadcrumbs, if: -> { request.format.html? }

    def index
      @company_evaluation = CompanyEvaluation.find params[:company_evaluation_id]
      title = t(".breadcrumb_title", title: @company_evaluation.title)
      @user_id = params[:user_id]
      @manager_user_id = params[:manager_user_id]
      @form_status = params[:form_status]
      @company = params[:company]
      add_to_breadcrumbs title, admin_company_evaluation_history_user_capabilities_path(company_evaluation_id: @company_evaluation.id)
      set_meta_tags(title: title)
      evaluation_user_capabilities = policy_scope(EvaluationUserCapability)
        .joins(:company_evaluation_template)
        .includes(:user, :job_role, :manager_user)
        .where(company_evaluation_template: {company_evaluation_id: @company_evaluation.id})
      @all_companies = policy_scope(EvaluationUserCapability)
        .joins(:company_evaluation_template)
        .where(company_evaluation_template: {company_evaluation_id: @company_evaluation.id})
        .select(:company).distinct.pluck(:company)
      if @user_id.present?
        evaluation_user_capabilities = evaluation_user_capabilities.where(user_id: @user_id)
      end
      if @manager_user_id.present?
        evaluation_user_capabilities = evaluation_user_capabilities.where(manager_user_id: @manager_user_id)
      end
      if @company.present?
        evaluation_user_capabilities = evaluation_user_capabilities.where(company: @company)
      end
      evaluation_user_capabilities = evaluation_user_capabilities.where(form_status: @form_status) if @form_status.present?
      @pagy, @evaluation_user_capabilities = pagy(evaluation_user_capabilities, items: current_user.preferred_page_length)
    end

    private

    def set_breadcrumbs
      @_breadcrumbs = [
        {text: t("layouts.sidebars.admin.header"),
         link: root_path},
        {text: t("evaluation.history_user_capabilities"),
         link: nil}
      ]
    end
  end
end
