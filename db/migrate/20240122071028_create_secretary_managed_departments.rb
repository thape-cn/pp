class CreateSecretaryManagedDepartments < ActiveRecord::Migration[7.1]
  def change
    create_table :secretary_managed_departments do |t|
      t.references :user, null: false
      t.string :managed_dept_code

      t.timestamps
    end
  end
end
