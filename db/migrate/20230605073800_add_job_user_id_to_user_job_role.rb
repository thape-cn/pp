class AddJobUserIdToUserJobRole < ActiveRecord::Migration[7.1]
  def change
    remove_columns(:users, :user_id, type: :string, null: false)
    add_column(:user_job_roles, :job_user_id, :string, null: true)
  end
end
