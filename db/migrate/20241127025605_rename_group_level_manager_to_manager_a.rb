class RenameGroupLevelManagerToManagerA < ActiveRecord::Migration[8.0]
  def change
    CompanyEvaluationTemplate.where(group_level: "manager").update_all(group_level: "manager_a")
  end
end
