class AddIdentifyAtmosphereToEvaluationUserCapability < ActiveRecord::Migration[7.1]
  def change
    add_column :evaluation_user_capabilities, :identify_business_pain, :decimal, precision: 5, scale: 2
    add_column :evaluation_user_capabilities, :best_plan, :decimal, precision: 5, scale: 2
    add_column :evaluation_user_capabilities, :mission_consensus, :decimal, precision: 5, scale: 2
    add_column :evaluation_user_capabilities, :collaboration, :decimal, precision: 5, scale: 2
    add_column :evaluation_user_capabilities, :set_vision_goals, :decimal, precision: 5, scale: 2
    add_column :evaluation_user_capabilities, :build_team, :decimal, precision: 5, scale: 2
    add_column :evaluation_user_capabilities, :team_atmosphere, :decimal, precision: 5, scale: 2
  end
end
