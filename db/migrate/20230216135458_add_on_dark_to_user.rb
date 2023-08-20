class AddOnDarkToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :on_dark, :boolean, default: false, null: false
  end
end
