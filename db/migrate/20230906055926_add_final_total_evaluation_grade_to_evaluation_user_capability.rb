class AddFinalTotalEvaluationGradeToEvaluationUserCapability < ActiveRecord::Migration[7.1]
  def change
    add_column :evaluation_user_capabilities, :final_total_evaluation_grade, :string
  end
end
