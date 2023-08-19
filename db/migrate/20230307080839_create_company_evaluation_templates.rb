class CreateCompanyEvaluationTemplates < ActiveRecord::Migration[7.1]
  def change
    create_table :company_evaluation_templates do |t|
      t.string :title, null: false
      t.references :company_evaluation, null: false, foreign_key: true
      t.integer :work_quality_pct, default: 35, null: false
      t.integer :work_load_pct, default: 50, null: false
      t.integer :work_attitude_pct, default: 15, null: false
      t.integer :work_subtotal_rate, default: 50, null: false
      t.integer :management_subtotal_rate, default: 15, null: false
      t.integer :profession_subtotal_rate, default: 35, null: false

      t.timestamps
    end
  end
end
