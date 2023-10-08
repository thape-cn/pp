class SetDefaultForCompanyEvaluationTemplate < ActiveRecord::Migration[7.1]
  def change
    change_column_default :company_evaluation_templates, :work_quality_matric, "grading_5_matric"
    change_column_default :company_evaluation_templates, :work_load_matric, "grading_5_matric"
    change_column_default :company_evaluation_templates, :work_attitude_matric, "grading_5_matric"
    change_column_default :company_evaluation_templates, :professional_management_matric, "grading_5_matric"
    change_column_default :company_evaluation_templates, :performance_matric, "grading_5_matric"
    change_column_default :company_evaluation_templates, :total_reverse_matric, "reverse_5_matric"
  end
end
