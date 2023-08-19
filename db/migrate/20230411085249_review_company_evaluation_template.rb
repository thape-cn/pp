class ReviewCompanyEvaluationTemplate < ActiveRecord::Migration[7.1]
  def change
    rename_column :company_evaluation_templates, :work_subtotal_rate, :performance_subtotal_rate
    add_column :company_evaluation_templates, :work_quality_matric, :string, default: "grading_3_matric"
    add_column :company_evaluation_templates, :work_load_matric, :string, default: "grading_3_matric"
    add_column :company_evaluation_templates, :work_attitude_matric, :string, default: "grading_3_matric"
    change_column_default :company_evaluation_templates, :professional_management_matric, "grading_3_matric"
  end
end
