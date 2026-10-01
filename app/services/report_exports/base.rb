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

    def each_with_performance_scores(scope, evaluation_association: nil)
      scope.find_in_batches do |batch|
        evaluations = evaluation_association ? batch.map(&evaluation_association) : batch
        scores = PerformanceScores.for(evaluations)
        batch.each { |record| yield record, scores }
      end
    end

    def capability_detail_labels
      Capability.performance_column_names.map { |name| [name, I18n.t("evaluation.#{name}_pct")] } +
        Capability.profession_column_label_and_names.map(&:reverse) +
        Capability.management_column_label_and_names.map(&:reverse) +
        Capability.calibration_column_names.map { |name| [name, I18n.t("calibration.#{name}")] }
    end
  end
end
