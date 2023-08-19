module Admin
  class HomeController < BaseController
    before_action :check_brower, if: -> { request.format.html? }
    include ExcelExport
    include Pagy::Backend
    helper_method :pagy

    def index
      @display_label = params[:label].presence
      @display_form_status = EvaluationUserCapability.form_status_options[@display_label]
      @company_evaluations = policy_scope(CompanyEvaluation).open_for_user
      @evaluation_user_capabilities = policy_scope(EvaluationUserCapability)
        .includes(:company_evaluation_template, :user, :manager_user)

      respond_to do |format|
        format.html { render }
        format.xlsx do
          send_file evaluation_progress_excel_file(@evaluation_user_capabilities),
            filename: "admin_evaluation_progress.xlsx"
        end
      end
    end

    protected

    def set_page_layout_data
      super
      @skip_title = true
    end
  end
end
