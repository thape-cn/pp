class AddRankPerformanceMetricToCompanyEvaluationTemplates < ActiveRecord::Migration[8.0]
  def change
    add_column :company_evaluation_templates, :rank_performance_metric, :string, default: "grading_rank_3_metric"
  end
end
