module QueuedReportExport
  extend ActiveSupport::Concern

  private

  def enqueue_report_export(report_type, options: {})
    report_export = current_user.report_exports.build(
      report_type: report_type,
      company_evaluation_id: params[:company_evaluation_id],
      locale: I18n.locale.to_s,
      options: options
    )
    authorize report_export, :create?
    # The worker applies the data policy scope when it generates the report.
    skip_policy_scope
    report_export.save!
    report_export.enqueue!
    redirect_to report_export_path(report_export, format: :html), status: :see_other
  end
end
