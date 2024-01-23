class AddAutoManagedToHrbpUserManagedDepartment < ActiveRecord::Migration[7.1]
  def change
    add_column :hrbp_user_managed_departments, :auto_managed, :boolean, null: false, default: false
    HrbpUserManagedDepartment.update_all(auto_managed: true)
  end
end
