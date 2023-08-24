module Admin
  class UsersController < BaseController
    after_action :verify_authorized, except: %i[index excel_report]
    after_action :verify_policy_scoped, only: %i[index excel_report]
    before_action :set_user, only: %i[edit update impersonation sign_in_as new_evaluation]
    before_action :set_breadcrumbs, if: -> { request.format.html? }

    def index
      users = policy_scope(User).all
      respond_to do |format|
        format.html do
          add_to_breadcrumbs t(".title")
        end
        format.json do
          render json: UsersDatatable.new(params, users: users, current_user: current_user, view_context: view_context)
        end
      end
      @_container_class = ""
    end

    def new
      @user = authorize User.new
      render layout: false
    end

    def create
      authorize User.create(user_params)
    end

    def edit
      render layout: false
    end

    def update
      @user.update_without_password(user_params)
      head :no_content
    end

    def impersonation
      render layout: false
    end

    def sign_in_as
      return redirect_to root_path, notice: t(".not_allow") unless current_user.admin?

      sign_in @user
      redirect_to root_path
    end

    def new_evaluation
      @company_evaluation_id = CompanyEvaluation.open_for_user.pluck(:id)
      @evaluation_user_capability = EvaluationUserCapability.new(user_id: @user.id)
      render layout: false
    end

    def excel_report
      user_job_roles = policy_scope(UserJobRole).all
      d2hrbp = HrbpUserManagedDepartment.hrbp_by_dept_code
      respond_to do |format|
        format.xlsx do
          p = Axlsx::Package.new
          wb = p.workbook

          wb.add_worksheet(name: "evaluation_progress") do |sheet|
            sheet.add_row [I18n.t("user.email"),
              I18n.t("user.chinese_name"),
              I18n.t("user.clerk_code"),
              I18n.t("user.hire_date"),
              I18n.t("user.user_is_active"),
              I18n.t("user.st_code"),
              I18n.t("user.company"),

              I18n.t("user.department"),
              I18n.t("user.dept_code"),
              I18n.t("user.title"),
              I18n.t("user.user_job_role_is_active"),
              I18n.t("user.job_level"),
              I18n.t("user.job_code"),
              I18n.t("user.job_family"),

              I18n.t("user.manager_user"),
              I18n.t("user.hrbp_name")]
            user_job_roles.find_each do |ujr|
              values = []
              values << ujr.user.email
              values << ujr.user.chinese_name
              values << ujr.user.clerk_code
              values << ujr.user.hire_date
              values << ujr.user.is_active
              values << ujr.job_role.st_code
              values << ujr.company

              values << ujr.department
              values << ujr.dept_code
              values << ujr.title
              values << ujr.is_active
              values << ujr.job_role.job_level
              values << ujr.job_role.job_code
              values << ujr.job_role.job_family

              values << ujr.manager_user&.chinese_name
              values << d2hrbp[ujr.dept_code]&.collect do |hrbp_user_managed_department|
                hrbp_user_managed_department.user.chinese_name
              end&.join(", ")
              row = sheet.add_row values
              row.cells[2].type = :string
              row.cells[2].value = ujr.user.clerk_code # Must overwrite again after setting cell type
              row.cells[5].type = :string
              row.cells[5].value = ujr.job_role.st_code
              row.cells[8].type = :string
              row.cells[8].value = ujr.dept_code
            end
          end

          temp_file = Tempfile.new("admin_excel_report")
          p.serialize temp_file
          send_file temp_file, filename: "all_pp_users.xlsx"
        end
      end
    end

    def change_manager_confirm
      authorize User
      render layout: false
    end

    def change_manager
      authorize User
      InitiationChangeManager.do_change(params[:file])
    end

    private

    def set_user
      @user = authorize User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:preferred_language, :wecom_id, managed_company_names: [], managed_dept_codes: [])
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
