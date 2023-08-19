module Admin
  class EvaluationRolesController < BaseController
    after_action :verify_authorized, except: :index
    after_action :verify_policy_scoped, only: :index
    before_action :set_evaluation_role, only: %i[edit update]
    before_action :set_breadcrumbs, if: -> { request.format.html? }

    def index
      evaluation_roles = policy_scope(EvaluationRole).all
      respond_to do |format|
        format.html do
          add_to_breadcrumbs t(".title")
        end
        format.json do
          render json: EvaluationRoleDatatable.new(params, evaluation_roles: evaluation_roles, view_context: view_context)
        end
      end
    end

    def edit
      render layout: false
    end

    def update
      @evaluation_role.update(evaluation_role_params)
      head :no_content
    end

    private

    def set_evaluation_role
      @evaluation_role = authorize EvaluationRole.find(params[:id])
    end

    def evaluation_role_params
      params.require(:evaluation_role).permit(capability_ids: [])
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
