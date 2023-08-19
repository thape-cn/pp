class CreateEucFormStatusHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :euc_form_status_histories do |t|
      t.references :evaluation_user_capability, null: false, foreign_key: true
      t.string :previous_form_status
      t.string :form_status
      t.references :user, null: false

      t.timestamps
    end
  end
end
