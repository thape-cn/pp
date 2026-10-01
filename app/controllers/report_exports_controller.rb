class ReportExportsController < ApplicationController
  include ActiveStorage::Streaming

  after_action :verify_authorized
  after_action :verify_policy_scoped
  before_action :set_report_export, except: :index
  before_action :disable_caching

  def index
    authorize ReportExport
    @report_exports = policy_scope(ReportExport).includes(:company_evaluation).with_attached_file.order(id: :desc).limit(100)
  end

  def show
  end

  def download
    return redirect_to report_export_path(@report_export), alert: t("report_exports.unavailable") unless @report_export.downloadable?

    send_blob_stream @report_export.file.blob, disposition: :attachment
  end

  def retry
    report_export = @report_export.dup
    report_export.assign_attributes(status: :queued, completed_at: nil, expires_at: nil)
    report_export.save!
    report_export.enqueue!
    redirect_to report_export_path(report_export), status: :see_other
  end

  private

  def set_report_export
    @report_export = authorize policy_scope(ReportExport).find(params[:id])
  end

  def disable_caching
    response.headers["Cache-Control"] = "no-store"
  end
end
