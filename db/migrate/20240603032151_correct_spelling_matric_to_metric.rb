class CorrectSpellingMatricToMetric < ActiveRecord::Migration[7.1]
  def change
    rename_column :company_evaluation_templates, :work_quality_matric, :work_quality_metric
    change_column_default :company_evaluation_templates, :work_quality_metric, "grading_5_metric"

    rename_column :company_evaluation_templates, :work_load_matric, :work_load_metric
    change_column_default :company_evaluation_templates, :work_load_metric, "grading_5_metric"

    rename_column :company_evaluation_templates, :work_attitude_matric, :work_attitude_metric
    change_column_default :company_evaluation_templates, :work_attitude_metric, "grading_5_metric"

    rename_column :company_evaluation_templates, :professional_management_matric, :professional_management_metric
    change_column_default :company_evaluation_templates, :professional_management_metric, "grading_5_metric"

    rename_column :company_evaluation_templates, :performance_matric, :performance_metric
    change_column_default :company_evaluation_templates, :performance_metric, "grading_5_metric"

    rename_column :company_evaluation_templates, :total_reverse_matric, :total_reverse_metric
    change_column_default :company_evaluation_templates, :total_reverse_metric, "reverse_5_metric"
  end
end
