class CreateCompanyEvaluations < ActiveRecord::Migration[7.1]
  def change
    create_table :company_evaluations do |t|
      t.string :title
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
