class AddWecomIdToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :wecom_id, :string
  end
end
