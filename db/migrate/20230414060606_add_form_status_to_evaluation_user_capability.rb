class AddFormStatusToEvaluationUserCapability < ActiveRecord::Migration[7.1]
  def change
    add_column :evaluation_user_capabilities, :form_status, :string, default: "initial"
  end
end
