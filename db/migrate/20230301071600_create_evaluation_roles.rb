class CreateEvaluationRoles < ActiveRecord::Migration[7.1]
  def change
    create_table :evaluation_roles do |t|
      t.string :role_name
      t.string :auxiliary

      t.timestamps
    end
    add_reference(:job_roles, :evaluation_role, foreign_key: true)
  end
end
