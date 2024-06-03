class AddOverallHintsToCompanyEvaluationTemplates < ActiveRecord::Migration[7.1]
  def change
    add_column :company_evaluation_templates, :self_overall_output_hint, :string
    add_column :company_evaluation_templates, :self_overall_improvement_hint, :string
    add_column :company_evaluation_templates, :self_overall_plan_hint, :string
    add_column :company_evaluation_templates, :manager_overall_output_hint, :string
    add_column :company_evaluation_templates, :manager_overall_improvement_hint, :string
    add_column :company_evaluation_templates, :manager_overall_plan_hint, :string
  end
end
