class AddObjResultExplainToJobRoleEvaluationPerformances < ActiveRecord::Migration[8.0]
  def change
    add_column :job_role_evaluation_performances, :obj_result_explain, :string
  end
end
