class FixExistingCompanyEvaluationTemplatesValue < ActiveRecord::Migration[7.1]
  def change
    CompanyEvaluationTemplate.where(work_quality_metric: "grading_5_matric").update_all(work_quality_metric: "grading_5_metric")
    CompanyEvaluationTemplate.where(work_load_metric: "grading_5_matric").update_all(work_load_metric: "grading_5_metric")
    CompanyEvaluationTemplate.where(work_attitude_metric: "grading_5_matric").update_all(work_attitude_metric: "grading_5_metric")
    CompanyEvaluationTemplate.where(professional_management_metric: "grading_5_matric").update_all(professional_management_metric: "grading_5_metric")
    CompanyEvaluationTemplate.where(performance_metric: "grading_5_matric").update_all(performance_metric: "grading_5_metric")
    CompanyEvaluationTemplate.where(total_reverse_metric: "reverse_5_matric").update_all(total_reverse_metric: "reverse_5_metric")
  end
end
