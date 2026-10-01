module ReportExports
  class Base
    def initialize(report_export)
      @report_export = report_export
    end

    private

    attr_reader :report_export

    def current_user
      report_export.user
    end

    def company_evaluation
      report_export.company_evaluation
    end

    def policy_scope(scope)
      Pundit.policy_scope!(current_user, scope)
    end
  end
end
