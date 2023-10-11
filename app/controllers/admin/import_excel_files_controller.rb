module Admin
  class ImportExcelFilesController < BaseController
    include Pagy::Backend
    after_action :verify_authorized, except: %i[index expender]
    before_action :set_company_evaluation, only: %i[index destroy_confirm]
    before_action :set_import_excel_file, only: %i[show destroy_confirm destroy]

    def index
      import_excel_files = policy_scope(ImportExcelFile)
        .where(company_evaluation_id: @company_evaluation.id)
        .order(id: :desc)
      @pagy, @import_excel_files = pagy(import_excel_files, items: current_user.preferred_page_length)
    end

    def show
      render layout: false
    end

    def destroy_confirm
      render layout: false
    end

    def destroy
      @import_excel_file.destroy
    end

    def expender
      render layout: false
    end

    private

    def set_company_evaluation
      @company_evaluation = CompanyEvaluation.find params[:company_evaluation_id]
    end

    def set_import_excel_file
      @import_excel_file = authorize ImportExcelFile.find(params[:id])
    end
  end
end
