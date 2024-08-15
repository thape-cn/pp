class CreateCorpPresidentManagedCompanies < ActiveRecord::Migration[7.1]
  def change
    create_table :corp_president_managed_companies do |t|
      t.references :user, null: false
      t.string :managed_company

      t.timestamps
    end
  end
end
