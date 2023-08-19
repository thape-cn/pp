class AddEnNameToJobRoleEvaluationPerformance < ActiveRecord::Migration[7.1]
  def change
    add_column :job_role_evaluation_performances, :en_name, :string
  end
end
