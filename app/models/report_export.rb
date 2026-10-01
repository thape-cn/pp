class ReportExport < ApplicationRecord
  GENERATORS = {
    "admin_evaluations" => "AdminEvaluations",
    "admin_evaluation_details" => "AdminEvaluationDetails",
    "admin_archived_evaluations" => "ArchivedEvaluations",
    "admin_calibrations" => "Calibrations",
    "admin_performances" => "Performances",
    "admin_users" => "Users",
    "admin_job_roles" => "JobRoles",
    "admin_progress" => "Progress",
    "hr_evaluations" => "ManagedEvaluations",
    "hr_evaluation_details" => "ManagedEvaluationDetails",
    "hr_progress" => "Progress",
    "cp_evaluations" => "ManagedEvaluations",
    "staff_evaluations" => "StaffEvaluations",
    "staff_evaluation_details" => "StaffEvaluationDetails",
    "staff_progress" => "Progress",
    "staff_printing" => "PrintedEvaluation"
  }.freeze
  EVALUATION_REPORTS = GENERATORS.keys.grep(/evaluations|evaluation_details|calibrations|performances/).freeze

  belongs_to :user
  belongs_to :company_evaluation, optional: true
  has_one_attached :file

  enum :status, %w[queued processing retrying completed failed].index_with(&:itself)

  attribute :options, default: -> { {} }

  validates :report_type, inclusion: {in: GENERATORS.keys}
  validates :locale, inclusion: {in: I18n.available_locales.map(&:to_s)}
  validates :company_evaluation, presence: true, if: -> { report_type.in?(EVALUATION_REPORTS) }

  def generator
    "ReportExports::#{GENERATORS.fetch(report_type)}".constantize.new(self)
  end

  def enqueue!
    raise "Report export was not enqueued" unless GenerateReportExportJob.perform_async(id)
  rescue => error
    update!(status: :failed)
    Rails.logger.error("Report export #{id} enqueue failed: #{error.class}: #{error.message}")
  end

  def pending?
    queued? || processing? || retrying?
  end

  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  def downloadable?
    completed? && !expired? && file.attached?
  end
end
