class AddIsFixedToJobRoleEvaluationPerformance < ActiveRecord::Migration[7.1]
  def change
    add_column :job_role_evaluation_performances, :obj_result_fixed, :boolean, default: true
  end
end
