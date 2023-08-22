module Admin
  class ImportExcelFilesController < BaseController
    include Pagy::Backend
    after_action :verify_authorized, except: %i[index expender]

    def index
      @pagy, @import_excel_files = pagy(policy_scope(ImportExcelFile), items: current_user.preferred_page_length)
    end

    def expender
      render layout: false
    end
  end
end
