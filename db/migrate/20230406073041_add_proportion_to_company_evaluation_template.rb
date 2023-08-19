class AddProportionToCompanyEvaluationTemplate < ActiveRecord::Migration[7.1]
  def change
    add_column :company_evaluation_templates, :pct_proportion, :integer, default: 100
    add_column :company_evaluation_templates, :rate_proportion, :integer, default: 0
  end
end
