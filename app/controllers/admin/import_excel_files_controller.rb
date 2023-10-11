module Admin
  class ImportExcelFilesController < BaseController
    include Pagy::Backend
    after_action :verify_authorized, except: %i[index expender]
    before_action :set_company_evaluation, only: %i[index show]

    def index
      import_excel_files = policy_scope(ImportExcelFile)
        .where(company_evaluation_id: @company_evaluation.id)
        .order(id: :desc)
      @pagy, @import_excel_files = pagy(import_excel_files, items: current_user.preferred_page_length)
    end

    def show
      @import_excel_file = authorize ImportExcelFile.find(params[:id])
      render layout: false
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
