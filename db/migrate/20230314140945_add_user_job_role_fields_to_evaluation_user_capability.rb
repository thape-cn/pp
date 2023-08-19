class AddUserJobRoleFieldsToEvaluationUserCapability < ActiveRecord::Migration[7.1]
  def change
    add_reference :evaluation_user_capabilities, :manager_user, null: true
    add_column :evaluation_user_capabilities, :company, :string, null: false
    add_column :evaluation_user_capabilities, :department, :string, null: false
    add_column :evaluation_user_capabilities, :dept_code, :string, null: false
    add_column :evaluation_user_capabilities, :title, :string, null: false
  end
end
