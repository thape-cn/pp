class RemoveSignStaffNameFromEvaluationUserCapability < ActiveRecord::Migration[7.1]
  def change
    remove_column :evaluation_user_capabilities, :sign_staff_name, :string
  end
end
