module Admin
  class ArchivedUserCapabilitiesController < BaseController
    include MetricHelper
    include Pagy::Backend
    after_action :verify_policy_scoped, only: %i[index excel_report confirm_restore restore]
    before_action :set_company_evaluation, only: %i[index excel_report confirm_restore restore]
    before_action :set_archived_evaluation_user_capability, only: %i[confirm_restore restore]
    before_action :set_breadcrumbs, if: -> { request.format.html? }

    def index
      title = t(".breadcrumb_title", title: @company_evaluation.title)
      add_to_breadcrumbs title, admin_company_evaluation_archived_user_capabilities_path(company_evaluation_id: @company_evaluation.id)
      set_meta_tags(title: title)
      company_evaluation_template_ids = CompanyEvaluationTemplate.where(company_evaluation_id: @company_evaluation.id).pluck(:id)
      archived_evaluation_user_capabilities = policy_scope(ArchivedEvaluationUserCapability)
        .where(company_evaluation_template_id: company_evaluation_template_ids)
        .order(deleted_time: :desc)
      @pagy, @archived_evaluation_user_capabilities = pagy(archived_evaluation_user_capabilities, items: current_user.preferred_page_length)
    end

    def confirm_restore
      render layout: false
    end

    def restore
      restore_hash = @archived_evaluation_user_capability.attributes.except("deleted_time", "deleted_user_id", "deleted_reason")
      EvaluationUserCapability.create(restore_hash)
      @archived_evaluation_user_capability.destroy
    end

    def excel_report
      company_evaluation_template_ids = CompanyEvaluationTemplate.where(company_evaluation_id: @company_evaluation.id).pluck(:id)
      archived_evaluation_user_capabilities = policy_scope(ArchivedEvaluationUserCapability)
        .where(company_evaluation_template_id: company_evaluation_template_ids)
        .order(deleted_time: :desc)
      respond_to do |format|
        format.xlsx do
          p = Axlsx::Package.new
          wb = p.workbook

          wb.add_worksheet(name: @company_evaluation.title) do |sheet|
            sheet.add_row [I18n.t("user.chinese_name"),
              I18n.t("user.user_id"),
              I18n.t("user.clerk_code"),
              I18n.t("user.st_code"),
              I18n.t("evaluation.evaluation_status"),
              I18n.t("user.company"),
              I18n.t("user.department"),

              I18n.t("user.dept_code"),
              I18n.t("admin.evaluation_templates.index.template_title"),
              I18n.t("user.manager_user"),
              I18n.t("user.user_id"),
              I18n.t("evaluation.manager_scored_total_evaluation_score"),
              I18n.t("evaluation.final_total_evaluation_score"),
              I18n.t("evaluation.deleted_user"),
              I18n.t("evaluation.deleted_reason"),
              I18n.t("form.deleted_time")]
            archived_evaluation_user_capabilities.find_each do |euc|
              values = []
              values << euc.user.chinese_name
              values << euc.user_id
              values << euc.user.clerk_code
              values << euc.job_role.st_code
              values << EvaluationUserCapability.form_status_options.invert[euc.form_status]
              values << euc.company
              values << euc.department

              values << euc.dept_code
              values << euc.company_evaluation_template.title
              values << euc.manager_user&.chinese_name
              values << euc.manager_user_id
              values << euc.manager_scored_in_metric
              values << euc.final_score_in_metric
              values << euc.deleted_user.chinese_name
              values << euc.deleted_reason
              values << euc.deleted_time

              row = sheet.add_row values
              row.cells[2].type = :string
              row.cells[2].value = euc.user.clerk_code # Must overwrite again after setting cell type
              row.cells[3].type = :string
              row.cells[3].value = euc.job_role.st_code
              row.cells[7].type = :string
              row.cells[7].value = euc.dept_code
            end
          end

          temp_file = Tempfile.new("admin_archived_excel_report")
          p.serialize temp_file
          send_file temp_file, filename: "#{@company_evaluation.title}.xlsx"
        end
      end
    end

    private

    def set_company_evaluation
      @company_evaluation = authorize CompanyEvaluation.find params[:company_evaluation_id]
    end

    def set_archived_evaluation_user_capability
      @archived_evaluation_user_capability = authorize policy_scope(ArchivedEvaluationUserCapability)
        .joins(:company_evaluation_template)
        .where(company_evaluation_template: {company_evaluation_id: @company_evaluation.id})
        .find(params[:id])
    end

    def set_breadcrumbs
      @_breadcrumbs = [
        {text: t("layouts.sidebars.admin.header"),
         link: root_path},
        {text: t("layouts.sidebars.admin.archived_user_capabilities"),
         link: nil}
      ]
    end
  end
end
