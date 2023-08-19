class AddChineseNameToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :chinese_name, :string, null: false
    add_column :users, :hire_date, :date, null: false
    add_column :users, :user_id, :string, null: false
    add_column :users, :clerk_code, :string, null: false
  end
end
