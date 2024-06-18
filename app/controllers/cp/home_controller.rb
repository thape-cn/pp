module CP
  class HomeController < BaseController
    def index
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
