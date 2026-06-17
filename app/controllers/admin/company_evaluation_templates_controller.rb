module Admin
  class CompanyEvaluationTemplatesController < BaseController
    include Pagy::Method

    after_action :verify_policy_scoped, only: :all
    before_action :set_breadcrumbs, if: -> { request.format.html? }

    def all
      add_to_breadcrumbs t(".title")
      @pagy, @company_evaluation_templates = pagy(:offset, policy_scope(CompanyEvaluationTemplate), limit: current_user.preferred_page_length)
    end

    def expender
      render layout: false
    end

    private

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
