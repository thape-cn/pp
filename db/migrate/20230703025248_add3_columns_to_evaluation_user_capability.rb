class Add3ColumnsToEvaluationUserCapability < ActiveRecord::Migration[7.1]
  def change
    add_column :evaluation_user_capabilities, :planning_interior, :integer
    add_column :evaluation_user_capabilities, :space_creativity, :integer
    add_column :evaluation_user_capabilities, :shape_interior, :integer
  end
end
