class AddEvaluationEndedToCompanyEvaluation < ActiveRecord::Migration[7.1]
  def change
    add_column :company_evaluations, :evaluation_ended, :boolean, default: false
  end
end
