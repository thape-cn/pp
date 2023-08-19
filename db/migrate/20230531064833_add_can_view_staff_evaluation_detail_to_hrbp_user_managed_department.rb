class AddCanViewStaffEvaluationDetailToHrbpUserManagedDepartment < ActiveRecord::Migration[7.1]
  def change
    add_column :hrbp_user_managed_departments, :can_view_staff_evaluation_detail, :boolean, null: false, default: true
  end
end
