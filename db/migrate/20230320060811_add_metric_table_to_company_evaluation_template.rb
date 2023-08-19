class AddMetricTableToCompanyEvaluationTemplate < ActiveRecord::Migration[7.1]
  def change
    add_column :company_evaluation_templates, :professional_management_matric, :string, default: "grading_9_matric"
    add_column :company_evaluation_templates, :performance_matric, :string, default: "grading_3_matric"
    add_column :company_evaluation_templates, :total_reverse_matric, :string, default: "grading_5_matric"
  end
end
