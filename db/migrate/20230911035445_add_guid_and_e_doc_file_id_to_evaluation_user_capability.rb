class AddGuidAndEDocFileIdToEvaluationUserCapability < ActiveRecord::Migration[7.1]
  def change
    add_column :evaluation_user_capabilities, :edoc_guid, :string
    add_column :evaluation_user_capabilities, :edoc_file_id, :string
  end
end
