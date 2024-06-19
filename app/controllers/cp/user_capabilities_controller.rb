module CP
  class UserCapabilitiesController < BaseController
    after_action :verify_policy_scoped, only: %i[index]
    before_action :set_breadcrumbs, if: -> { request.format.html? }

    def index
      @company_evaluation = CompanyEvaluation.find params[:company_evaluation_id]
      title = t(".breadcrumb_title", title: @company_evaluation.title)
      set_meta_tags(title: title)
      evaluation_user_capabilities = policy_scope(EvaluationUserCapability)
        .joins(:company_evaluation_template)
        .includes(:user, :job_role, :manager_user)
        .where(company_evaluation_template: {company_evaluation_id: @company_evaluation.id})
    end

    private

    def set_breadcrumbs
      @_breadcrumbs = [
        {text: t("layouts.sidebars.corp_president.header"),
         link: cp_root_path},
        {text: t("layouts.sidebars.corp_president.user_capabilities"),
         link: nil}
      ]
    end
  end
end
