class AddDescriptionToEvaluationRoleCapability < ActiveRecord::Migration[7.1]
  def change
    add_column :evaluation_role_capabilities, :erc_description, :string
  end
end
