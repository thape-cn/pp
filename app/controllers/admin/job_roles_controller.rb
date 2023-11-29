module Admin
  class JobRolesController < BaseController
    after_action :verify_authorized, except: %i[index excel_report]
    after_action :verify_policy_scoped, only: %i[index excel_report]
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

    def excel_report
      job_roles = policy_scope(JobRole).all
      respond_to do |format|
        format.xlsx do
          p = Axlsx::Package.new
          wb = p.workbook

          wb.add_worksheet(name: "job_roles") do |sheet|
            sheet.add_row ["ID",
              I18n.t("user.st_code"),
              I18n.t("user.job_level"),
              I18n.t("user.job_code"),
              I18n.t("user.job_family"),

              I18n.t("form.created_at"),
              I18n.t("form.updated_at"),
              I18n.t("capability.evaluation_roles")]
            job_roles.find_each do |jr|
              values = []
              values << jr.id
              values << jr.st_code
              values << jr.job_level
              values << jr.job_code
              values << jr.job_family

              values << jr.created_at.to_fs(:db_short)
              values << jr.updated_at.to_fs(:db_short)
              values << jr.evaluation_role&.role_name
              row = sheet.add_row values
              row.cells[1].type = :string
              row.cells[1].value = jr.st_code
            end
          end

          temp_file = Tempfile.new("admin_excel_report")
          p.serialize temp_file
          send_file temp_file, filename: "all_job_roles.xlsx"
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
