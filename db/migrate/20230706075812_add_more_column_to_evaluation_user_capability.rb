class AddMoreColumnToEvaluationUserCapability < ActiveRecord::Migration[7.1]
  def change
    add_column :evaluation_user_capabilities, :graphic_interior_aico, :integer
    add_column :evaluation_user_capabilities, :presentation_interior_aico, :integer
    add_column :evaluation_user_capabilities, :implementation_interior_aico, :integer
  end
end
