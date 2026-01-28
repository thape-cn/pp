class AddDesignProjectTeamCapabilitiesToArchivedEucs < ActiveRecord::Migration[8.0]
  def change
    add_column :archived_evaluation_user_capabilities, :design_capability, :decimal, precision: 5, scale: 2
    add_column :archived_evaluation_user_capabilities, :project_management, :decimal, precision: 5, scale: 2
    add_column :archived_evaluation_user_capabilities, :team_management, :decimal, precision: 5, scale: 2
  end
end
