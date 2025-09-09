module Staff
  class EvaluationProgressesController < BaseController
    include ExcelExport
    include Pagy::Backend

    helper_method :pagy

    def show
      if current_user.hrbp_user_managed_departments.present? || current_user.secretary_managed_departments.present?
        @display_label = params[:label].presence
        @display_form_status = EvaluationUserCapability.form_status_options[@display_label]
        @company_evaluations = policy_scope(CompanyEvaluation).open_for_user
        @company_evaluation_ids = @company_evaluations.pluck(:id)
        dept_codes = current_user.hrbp_user_managed_departments.collect(&:managed_dept_code)
        dept_codes = current_user.secretary_managed_departments.collect(&:managed_dept_code) if dept_codes.blank?
        @evaluation_user_capabilities = EvaluationUserCapability
          .includes(:company_evaluation_template, :user, :manager_user)
          .where(company_evaluation_template: {company_evaluation_id: @company_evaluation_ids})
          .where(dept_code: dept_codes)

        respond_to do |format|
          format.html { render }
          format.xlsx do
            send_file evaluation_progress_excel_file(@evaluation_user_capabilities),
              filename: "evaluation_progress.xlsx"
          end
        end
      else
        redirect_to root_path
      end
    end

    protected

    def set_page_layout_data
      super
      @skip_title = true
    end
  end
end
