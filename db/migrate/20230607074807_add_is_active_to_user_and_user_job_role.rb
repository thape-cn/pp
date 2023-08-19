class AddIsActiveToUserAndUserJobRole < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :is_active, :boolean, null: false, default: false
    add_column :user_job_roles, :is_active, :boolean, null: false, default: false
  end
end
