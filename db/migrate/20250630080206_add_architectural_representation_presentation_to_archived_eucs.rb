class AddArchitecturalRepresentationPresentationToArchivedEucs < ActiveRecord::Migration[8.0]
  def change
    add_column :archived_evaluation_user_capabilities, :architectural_representation_presentation, :decimal, precision: 5, scale: 2
  end
end
