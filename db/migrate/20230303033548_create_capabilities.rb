class CreateCapabilities < ActiveRecord::Migration[7.1]
  def change
    create_table :capabilities do |t|
      t.string :en_name, null: true
      t.string :name, null: true
      t.string :description
      t.string :category_name, null: true

      t.timestamps
    end
    create_table :evaluation_role_capabilities do |t|
      t.references :evaluation_role, null: false, foreign_key: true
      t.references :capability, null: false, foreign_key: true

      t.timestamps
    end
  end
end
