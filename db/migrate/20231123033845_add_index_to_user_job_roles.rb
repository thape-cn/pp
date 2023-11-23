class AddIndexToUserJobRoles < ActiveRecord::Migration[7.1]
  def change
    add_index :user_job_roles, [:user_id, :job_role_id], unique: true
  end
end
