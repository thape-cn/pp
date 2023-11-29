class AddBonusPeriodToCompanyEvaluation < ActiveRecord::Migration[7.1]
  def change
    add_column :company_evaluations, :bonus_period, :string
  end
end
