class AddGroupLevelToCompanyEvaluationTemplate < ActiveRecord::Migration[7.1]
  def change
    add_column :company_evaluation_templates, :group_level, :string, default: "staff"
  end
end
