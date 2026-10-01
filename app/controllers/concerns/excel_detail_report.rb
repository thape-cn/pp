module ExcelDetailReport
  extend ActiveSupport::Concern

  included do
    after_action :verify_policy_scoped, only: %i[excel_detail_report]
  end

  def excel_detail_report
    enqueue_report_export("admin_evaluation_details")
  end
end
