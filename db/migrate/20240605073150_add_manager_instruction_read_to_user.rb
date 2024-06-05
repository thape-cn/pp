class AddManagerInstructionReadToUser < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :read_manager_instruction, :boolean, default: false, null: false
  end
end
