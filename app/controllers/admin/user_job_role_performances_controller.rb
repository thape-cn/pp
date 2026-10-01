module Admin
  class UserJobRolePerformancesController < BaseController
    after_action :verify_authorized, except: %i[index expender excel_report]
    after_action :verify_policy_scoped, only: %i[index excel_report]
    before_action :set_job_role_evaluation_performance, only: %i[edit update]
    before_action :set_company_evaluation, only: %i[new create excel_report]
    before_action :set_breadcrumbs, if: -> { request.format.html? }

    def index
      @company_evaluation = CompanyEvaluation.find params[:company_evaluation_id]
      @user_id = params[:user_id].presence
      @manager_user_id = params[:manager_user_id].presence
      job_role_evaluation_performances = policy_scope(JobRoleEvaluationPerformance)
        .joins(:user)
        .where(company_evaluation_id: @company_evaluation.id)
      job_role_evaluation_performances = job_role_evaluation_performances.where(user_id: @user_id) if @user_id.present?
      if @manager_user_id.present?
        job_role_evaluation_performances = job_role_evaluation_performances.managed_by(@manager_user_id)
      end
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
      import_excel_file = current_user.import_excel_files
        .create(company_evaluation_id: @company_evaluation.id,
          title: @company_evaluation.title, import_type: "new_performance")
      import_excel_file.excel_file.attach(params[:file])
      ImportNewPerformanceJob.perform_async(import_excel_file.id)
    end

    def excel_report
      enqueue_report_export("admin_performances")
    end

    private

    def set_job_role_evaluation_performance
      @job_role_evaluation_performance = authorize JobRoleEvaluationPerformance.find(params[:id])
    end

    def set_company_evaluation
      @company_evaluation = CompanyEvaluation.find(params[:company_evaluation_id])
    end

    def job_role_evaluation_performance_params
      params.require(:job_role_evaluation_performance).permit(:obj_name, :obj_metric, :obj_weight_pct, :obj_result, :obj_result_explain, :obj_result_fixed)
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
