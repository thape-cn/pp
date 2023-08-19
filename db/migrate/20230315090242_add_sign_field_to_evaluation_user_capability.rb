class AddSignFieldToEvaluationUserCapability < ActiveRecord::Migration[7.1]
  def change
    add_column :evaluation_user_capabilities, :sign_staff_name, :string
    add_column :evaluation_user_capabilities, :sign_date, :date
  end
end
