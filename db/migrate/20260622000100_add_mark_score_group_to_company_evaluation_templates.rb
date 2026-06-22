class AddMarkScoreGroupToCompanyEvaluationTemplates < ActiveRecord::Migration[8.0]
  def change
    add_column :company_evaluation_templates, :mark_score_group, :integer, default: 4
  end
end
