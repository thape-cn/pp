class RemoveAuxiliaryFromEvaluationRole < ActiveRecord::Migration[7.1]
  def change
    remove_columns :evaluation_roles, :auxiliary, type: :string
  end
end
