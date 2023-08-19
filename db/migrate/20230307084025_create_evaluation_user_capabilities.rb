class CreateEvaluationUserCapabilities < ActiveRecord::Migration[7.1]
  def change
    create_table :evaluation_user_capabilities do |t|
      t.references :company_evaluation_template, null: false, index: false
      t.references :user, null: false, foreign_key: true
      t.references :job_role, null: false, foreign_key: true
      t.integer :work_quality
      t.integer :work_quality_final
      t.integer :work_load
      t.integer :work_load_final
      t.integer :work_attitude
      t.integer :work_attitude_final

      t.timestamps
    end
  end
end
