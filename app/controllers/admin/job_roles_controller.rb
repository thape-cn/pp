module Admin
  class JobRolesController < BaseController
    after_action :verify_authorized, except: :index
    after_action :verify_policy_scoped, only: :index
    before_action :set_job_role, only: %i[edit update]
    before_action :set_breadcrumbs, if: -> { request.format.html? }

    def index
      job_roles = policy_scope(JobRole).all
      respond_to do |format|
        format.html do
          add_to_breadcrumbs t(".title")
        end
        format.json do
          render json: JobRoleDatatable.new(params, job_roles: job_roles, view_context: view_context)
        end
      end
    end

    def edit
      render layout: false
    end

    def update
      @job_role.update(job_role_params)
      head :no_content
    end

    private

    def set_job_role
      @job_role = authorize JobRole.find(params[:id])
    end

    def job_role_params
      params.require(:job_role).permit(:evaluation_role_id)
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
