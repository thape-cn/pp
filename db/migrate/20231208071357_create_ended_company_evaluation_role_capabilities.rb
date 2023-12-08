class CreateEndedCompanyEvaluationRoleCapabilities < ActiveRecord::Migration[7.1]
  def change
    create_table :ended_company_evaluation_role_capabilities do |t|
      t.references :company_evaluation, null: false
      t.references :evaluation_role, null: false
      t.references :capability, null: false
      t.string :cerc_description, null: false

      t.timestamps
    end
  end
end
