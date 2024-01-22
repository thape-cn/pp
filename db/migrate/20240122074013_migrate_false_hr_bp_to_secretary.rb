class MigrateFalseHRBpToSecretary < ActiveRecord::Migration[7.1]
  def change
    HrbpUserManagedDepartment.where(auto_generated: false, can_view_staff_evaluation_detail: false).each do |hmd|
      SecretaryManagedDepartment.create(user_id: hmd.user_id, managed_dept_code: hmd.managed_dept_code)
      hmd.destroy
    end
    remove_column :hrbp_user_managed_departments, :auto_generated, :boolean
    remove_column :hrbp_user_managed_departments, :can_view_staff_evaluation_detail, :boolean
  end
end
