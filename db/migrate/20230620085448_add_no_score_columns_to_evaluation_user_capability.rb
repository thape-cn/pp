class AddNoScoreColumnsToEvaluationUserCapability < ActiveRecord::Migration[7.1]
  def change
    add_column :evaluation_user_capabilities, :capability_columns_all_null, :boolean, null: false, default: false
  end
end
