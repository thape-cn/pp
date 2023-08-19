module Admin
  class CapabilitiesController < BaseController
    after_action :verify_authorized, except: :index
    after_action :verify_policy_scoped, only: :index
    before_action :set_capability, only: %i[edit update]
    before_action :set_breadcrumbs, if: -> { request.format.html? }

    def index
      capabilities = policy_scope(Capability).all
      respond_to do |format|
        format.html do
          add_to_breadcrumbs t(".title")
        end
        format.json do
          render json: CapabilityDatatable.new(params, capabilities: capabilities, view_context: view_context)
        end
      end
    end

    def edit
      render layout: false
    end

    def update
      @capability.update(capability_params)
      head :no_content
    end

    private

    def set_capability
      @capability = authorize Capability.find(params[:id])
    end

    def capability_params
      params.require(:capability).permit(:en_name, :name, :description, :category_name)
    end

    def set_breadcrumbs
      @_breadcrumbs = [
        {text: t("layouts.sidebars.admin.header"),
         link: root_path},
        {text: t("layouts.sidebars.admin.account"),
         link: nil}
      ]
    end
  end
end
