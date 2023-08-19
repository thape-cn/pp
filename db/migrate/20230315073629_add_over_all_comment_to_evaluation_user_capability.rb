class AddOverAllCommentToEvaluationUserCapability < ActiveRecord::Migration[7.1]
  def change
    add_column :evaluation_user_capabilities, :self_overall_output, :text
    add_column :evaluation_user_capabilities, :self_overall_improvement, :text
    add_column :evaluation_user_capabilities, :self_overall_plan, :text
    add_column :evaluation_user_capabilities, :manager_overall_output, :text
    add_column :evaluation_user_capabilities, :manager_overall_improvement, :text
    add_column :evaluation_user_capabilities, :manager_overall_plan, :text
  end
end
