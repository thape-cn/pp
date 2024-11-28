class RemoveTotalReverseMetricFromCompanyEvaluationTemplate < ActiveRecord::Migration[8.0]
  def change
    remove_column :company_evaluation_templates, :total_reverse_metric, type: :string, default: "reverse_5_metric"
  end
end
