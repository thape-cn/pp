module ReportExports
  class PerformanceScores
    def self.for(evaluations)
      evaluations = evaluations.select do |evaluation|
        template = evaluation.company_evaluation_template
        evaluation.calibration_performance_score.nil? &&
          !template.manager_b? && !template.auxiliary? && !template.supervisor?
      end
      return {} if evaluations.empty?

      # Match legacy imports by their business keys, including rows without an
      # evaluation_user_capability_id. Group by evaluation ID so multiple roles,
      # departments and periods for the same employee stay separate.
      EvaluationUserCapability.where(id: evaluations.map(&:id).uniq)
        .joins(:job_role, :company_evaluation_template)
        .joins(<<~SQL.squish)
          INNER JOIN job_role_evaluation_performances report_performances
            ON report_performances.user_id = evaluation_user_capabilities.user_id
            AND report_performances.dept_code = evaluation_user_capabilities.dept_code
            AND report_performances.st_code = job_roles.st_code
            AND report_performances.company_evaluation_id = company_evaluation_templates.company_evaluation_id
        SQL
        .group("evaluation_user_capabilities.id")
        .sum("report_performances.obj_weight_pct / 100.0 * report_performances.obj_result")
    end
  end
end
