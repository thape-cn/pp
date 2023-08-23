module Admin
  class ImportExcelFilesController < BaseController
    include Pagy::Backend
    after_action :verify_authorized, except: %i[index expender]
    before_action :set_company_evaluation, only: %i[index]

    def index
      import_excel_files = policy_scope(ImportExcelFile).where(company_evaluation_id: @company_evaluation.id)
      @pagy, @import_excel_files = pagy(import_excel_files, items: current_user.preferred_page_length)
    end

    def expender
      render layout: false
    end

    private

    def set_company_evaluation
      @company_evaluation = authorize CompanyEvaluation.find params[:company_evaluation_id]
    end
  end
end