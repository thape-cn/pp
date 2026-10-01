module Admin
  class HomeController < BaseController
    before_action :check_brower, if: -> { request.format.html? }
    include Pagy::Method

    helper_method :pagy

    def index
      return enqueue_report_export("admin_progress") if request.format.xlsx?

      @display_label = params[:label].presence
      @display_form_status = EvaluationUserCapability.form_status_options[@display_label]
      @company_evaluations = policy_scope(CompanyEvaluation).open_for_user
      @company_evaluation_ids = @company_evaluations.pluck(:id)
      @evaluation_user_capabilities = policy_scope(EvaluationUserCapability)
        .includes(:company_evaluation_template, :user, :manager_user)
        .where(company_evaluation_template: {company_evaluation_id: @company_evaluation_ids})

      respond_to do |format|
        format.html { render }
      end
    end

    protected

    def set_page_layout_data
      super
      @skip_title = true
    end
  end
end
