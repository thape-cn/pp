module Admin
  class EvaluationTemplatesController < BaseController
    after_action :verify_authorized, except: :index
    after_action :verify_policy_scoped, only: :index
    before_action :set_company_evaluation, only: %i[new create edit update]
    before_action :set_company_evaluation_template, only: %i[edit update]
    before_action :set_breadcrumbs, if: -> { request.format.html? }

    def index
      @company_evaluation = CompanyEvaluation.find params[:company_evaluation_id]
      title = t(".breadcrumb_title", title: @company_evaluation.title)
      add_to_breadcrumbs title
      set_meta_tags(title: title)
      @company_evaluation_templates = policy_scope(CompanyEvaluationTemplate)
        .where(company_evaluation_id: @company_evaluation.id)
    end

    def new
      @company_evaluation_template = authorize CompanyEvaluationTemplate.new
      render layout: false
    end

    def create
      authorize CompanyEvaluationTemplate.create(company_evaluation_template_params.merge(company_evaluation_id: @company_evaluation.id))
    end

    def edit
      render layout: false
    end

    def update
      @company_evaluation_template.update(company_evaluation_template_params)
    end

    private

    def set_company_evaluation
      @company_evaluation = authorize CompanyEvaluation.find(params[:company_evaluation_id])
    end

    def set_company_evaluation_template
      @company_evaluation_template = authorize CompanyEvaluationTemplate.find(params[:id])
    end

    def company_evaluation_template_params
      params.require(:company_evaluation_template)
        .permit(:title, :group_level, :brief, :pct_proportion, :rate_proportion,
          :work_quality_pct, :work_load_pct, :work_attitude_pct,
          :work_quality_metric, :work_load_metric, :work_attitude_metric,
          :management_subtotal_rate, :profession_subtotal_rate, :performance_subtotal_rate,
          :professional_management_metric, :performance_metric, :total_reverse_metric,
          :self_overall_output_hint, :self_overall_improvement_hint, :self_overall_plan_hint,
          :manager_overall_output_hint, :manager_overall_improvement_hint, :manager_overall_plan_hint)
    end

    def set_breadcrumbs
      @_breadcrumbs = [
        {text: t("layouts.sidebars.admin.header"),
         link: root_path},
        {text: t("layouts.sidebars.admin.evaluation"),
         link: nil},
        {text: t("layouts.sidebars.admin.company_evaluation_templates"),
         link: all_admin_company_evaluation_templates_path}
      ]
    end
  end
end
