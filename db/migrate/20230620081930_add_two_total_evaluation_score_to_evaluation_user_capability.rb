class AddTwoTotalEvaluationScoreToEvaluationUserCapability < ActiveRecord::Migration[7.1]
  def change
    add_column :evaluation_user_capabilities, :manager_scored_total_evaluation_score, :float, null: true
    add_column :evaluation_user_capabilities, :final_total_evaluation_score, :float, null: true
  end
end
