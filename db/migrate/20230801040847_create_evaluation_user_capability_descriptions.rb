class CreateEvaluationUserCapabilityDescriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :evaluation_user_capability_descriptions do |t|
      t.references :company_evaluation_template, null: false, foreign_key: false
      t.references :user, null: false, foreign_key: false
      t.references :capability, null: false, foreign_key: false
      t.text :description

      t.timestamps
    end
  end
end
