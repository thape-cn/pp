class AddBriefToCompanyEvaluationTemplate < ActiveRecord::Migration[7.1]
  def change
    add_column :company_evaluation_templates, :brief, :text
  end
end
