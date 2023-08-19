module Admin
  class CompanyEvaluationsController < BaseController
    include Pagy::Backend
    after_action :verify_authorized, except: :index
    after_action :verify_policy_scoped, only: :index
    before_action :set_company_evaluation, only: %i[edit update confirm_remove_leaving_employee_eucs remove_leaving_employee_eucs]
    before_action :set_breadcrumbs, if: -> { request.format.html? }

    def index
      add_to_breadcrumbs t(".title")
      @pagy, @company_evaluations = pagy(policy_scope(CompanyEvaluation), items: current_user.preferred_page_length)
    end

    def new
      @company_evaluation = authorize CompanyEvaluation.new
      render layout: false
    end

    def create
      authorize CompanyEvaluation.create(company_evaluation_params)
    end

    def edit
      render layout: false
    end

    def update
      @company_evaluation.update(company_evaluation_params)
    end

    def confirm_remove_leaving_employee_eucs
      render layout: false
    end

    def remove_leaving_employee_eucs
      @company_evaluation.remove_leaving_employee_eucs
    end

    private

    def company_evaluation_params
      params.require(:company_evaluation).permit(:title, :start_date, :end_date)
    end

    def set_company_evaluation
      @company_evaluation = authorize CompanyEvaluation.find(params[:id])
    end

    def set_breadcrumbs
      @_breadcrumbs = [
        {text: t("layouts.sidebars.admin.header"),
         link: root_path},
        {text: t("layouts.sidebars.admin.evaluation"),
         link: nil}
      ]
    end
  end
end
