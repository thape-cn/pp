module Admin
  class ArchivedUserCapabilitiesController < BaseController
    include MetricHelper
    include Pagy::Method

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
      @pagy, @archived_evaluation_user_capabilities = pagy(:offset, archived_evaluation_user_capabilities, limit: current_user.preferred_page_length)
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
      enqueue_report_export("admin_archived_evaluations")
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
