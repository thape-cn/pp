class CreateJobRoleEvaluationPerformances < ActiveRecord::Migration[7.1]
  def change
    create_table :job_role_evaluation_performances do |t|
      t.references :user, null: false, foreign_key: true
      t.references :company_evaluation, null: false, foreign_key: true
      t.string :import_guid, null: false
      t.string :dept_code, null: false
      t.string :st_code, null: false
      t.string :obj_name, null: false
      t.text :obj_metric
      t.integer :obj_weight_pct, null: false, default: 0
      t.integer :obj_result

      t.timestamps
    end
  end
end
