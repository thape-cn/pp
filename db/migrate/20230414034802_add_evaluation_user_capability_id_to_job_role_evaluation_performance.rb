class AddEvaluationUserCapabilityIdToJobRoleEvaluationPerformance < ActiveRecord::Migration[7.1]
  def change
    add_reference :job_role_evaluation_performances, :evaluation_user_capability, null: true, foreign_key: true
  end
end
