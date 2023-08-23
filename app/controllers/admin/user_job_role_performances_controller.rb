module Admin
  class UserJobRolePerformancesController < BaseController
    after_action :verify_authorized, except: %i[index expender excel_report]
    after_action :verify_policy_scoped, only: %i[index excel_report]
    before_action :set_job_role_evaluation_performance, only: %i[edit update]
    before_action :set_company_evaluation, only: %i[new create excel_report]
    before_action :set_breadcrumbs, if: -> { request.format.html? }

    def index
      @company_evaluation = CompanyEvaluation.find params[:company_evaluation_id]
      job_role_evaluation_performances = policy_scope(JobRoleEvaluationPerformance)
        .joins(:user)
        .where(company_evaluation_id: @company_evaluation.id)
      respond_to do |format|
        format.html do
          title = t(".breadcrumb_title", title: @company_evaluation.title)
          add_to_breadcrumbs title
          set_meta_tags(title: title)
        end
        format.json do
          render json: JobRoleEvaluationPerformanceDatatable.new(params,
            job_role_evaluation_performances: job_role_evaluation_performances,
            view_context: view_context)
        end
      end
    end

    def expender
      render layout: false
    end

    def edit
      render layout: false
    end

    def update
      @job_role_evaluation_performance.update(job_role_evaluation_performance_params)
      head :no_content
    end

    def new
      authorize JobRoleEvaluationPerformance
      render layout: false
    end

    def create
      authorize JobRoleEvaluationPerformance
      InitiationNewPerformance.do_import(@company_evaluation, params[:file])
    end

    def excel_report
      job_role_evaluation_performances = policy_scope(JobRoleEvaluationPerformance)
        .includes(:user, :evaluation_user_capability)
        .where(company_evaluation_id: @company_evaluation.id)
      respond_to do |format|
        format.xlsx do
          p = Axlsx::Package.new
          wb = p.workbook

          wb.add_worksheet(name: @company_evaluation.title) do |sheet|
            sheet.add_row [I18n.t("user.chinese_name"),
              I18n.t("user.user_id"),
              I18n.t("user.clerk_code"),
              I18n.t("user.st_code"),
              I18n.t("user.company"),
              I18n.t("user.department"),
              I18n.t("user.dept_code"),

              I18n.t("evaluation.import_guid"),
              I18n.t("evaluation.obj_name"),
              I18n.t("evaluation.obj_weight_pct"),
              I18n.t("evaluation.obj_result"),
              I18n.t("capability.en_name"),
              I18n.t("evaluation.obj_metric"),
              I18n.t("evaluation.obj_result_fixed")]
            job_role_evaluation_performances.find_each do |jrep|
              values = []
              values << jrep.user.chinese_name
              values << jrep.user_id
              values << jrep.user.clerk_code
              values << jrep.st_code
              values << UserJobRole.company_by_dept_code[jrep.dept_code]
              values << UserJobRole.department_by_dept_code[jrep.dept_code]
              values << jrep.dept_code

              values << jrep.import_guid
              values << jrep.obj_name
              values << jrep.obj_weight_pct
              values << jrep.obj_result
              values << jrep.en_name
              values << jrep.obj_metric
              values << (jrep.obj_result_fixed? ? "Y" : "N")
              row = sheet.add_row values
              row.cells[2].type = :string
              row.cells[2].value = jrep.user.clerk_code # Must overwrite again after setting cell type
              row.cells[3].type = :string
              row.cells[3].value = jrep.st_code
              row.cells[6].type = :string
              row.cells[6].value = jrep.dept_code
              row.cells[7].type = :string
              row.cells[7].value = jrep.import_guid
            end
          end

          temp_file = Tempfile.new("admin_excel_report")
          p.serialize temp_file
          send_file temp_file, filename: "#{@company_evaluation.title}.xlsx"
        end
      end
    end

    private

    def set_job_role_evaluation_performance
      @job_role_evaluation_performance = authorize JobRoleEvaluationPerformance.find(params[:id])
    end

    def set_company_evaluation
      @company_evaluation = CompanyEvaluation.find(params[:company_evaluation_id])
    end

    def job_role_evaluation_performance_params
      params.require(:job_role_evaluation_performance).permit(:obj_name, :obj_metric, :obj_weight_pct, :obj_result, :obj_result_fixed)
    end

    def set_breadcrumbs
      @_breadcrumbs = [
        {text: t("layouts.sidebars.admin.header"),
         link: root_path},
        {text: t("layouts.sidebars.admin.user_performances"),
         link: nil}
      ]
    end
  end
end
