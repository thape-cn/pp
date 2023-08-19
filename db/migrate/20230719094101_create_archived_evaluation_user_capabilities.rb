class CreateArchivedEvaluationUserCapabilities < ActiveRecord::Migration[7.1]
  def change
    create_table :archived_evaluation_user_capabilities do |t|
      t.bigint :company_evaluation_template_id, null: false
      t.bigint :user_id, null: false
      t.bigint :job_role_id, null: false
      t.decimal :work_quality, precision: 5, scale: 2
      t.decimal :annual_output, precision: 5, scale: 2
      t.decimal :work_load, precision: 5, scale: 2
      t.decimal :coaching, precision: 5, scale: 2
      t.decimal :work_attitude, precision: 5, scale: 2
      t.decimal :concept, precision: 5, scale: 2
      t.bigint :manager_user_id
      t.string :company, null: false
      t.string :department, null: false
      t.string :dept_code, null: false
      t.string :title, null: false
      t.text :self_overall_output
      t.text :self_overall_improvement
      t.text :self_overall_plan
      t.text :manager_overall_output
      t.text :manager_overall_improvement
      t.text :manager_overall_plan
      t.date :sign_date
      t.string :form_status, default: "initial"
      t.decimal :cooperation, precision: 5, scale: 2
      t.decimal :craftsmanship, precision: 5, scale: 2
      t.decimal :customer_insight, precision: 5, scale: 2
      t.decimal :customer_needs, precision: 5, scale: 2
      t.decimal :customer_needs_non, precision: 5, scale: 2
      t.decimal :goal_achieved, precision: 5, scale: 2
      t.decimal :graphic_interior, precision: 5, scale: 2
      t.decimal :graphic_landscape, precision: 5, scale: 2
      t.decimal :graphic_planning, precision: 5, scale: 2
      t.decimal :graphic_quality, precision: 5, scale: 2
      t.decimal :graphic_quality_landscape, precision: 5, scale: 2
      t.decimal :high_quality, precision: 5, scale: 2
      t.decimal :high_efficiency, precision: 5, scale: 2
      t.decimal :implementation, precision: 5, scale: 2
      t.decimal :implementation_landscape, precision: 5, scale: 2
      t.decimal :innovation, precision: 5, scale: 2
      t.decimal :learning, precision: 5, scale: 2
      t.decimal :logic, precision: 5, scale: 2
      t.decimal :logic_landscape, precision: 5, scale: 2
      t.decimal :norms, precision: 5, scale: 2
      t.decimal :norms_landscape, precision: 5, scale: 2
      t.decimal :onsite, precision: 5, scale: 2
      t.decimal :onsite_landscape, precision: 5, scale: 2
      t.decimal :organizational_capabilities, precision: 5, scale: 2
      t.decimal :planning, precision: 5, scale: 2
      t.decimal :planning_landscape, precision: 5, scale: 2
      t.decimal :presentation, precision: 5, scale: 2
      t.decimal :presentation_arch, precision: 5, scale: 2
      t.decimal :presentation_landscape, precision: 5, scale: 2
      t.decimal :presentation_planning, precision: 5, scale: 2
      t.decimal :product_design_landscape, precision: 5, scale: 2
      t.decimal :professional_level, precision: 5, scale: 2
      t.decimal :realization, precision: 5, scale: 2
      t.decimal :realization_landscape, precision: 5, scale: 2
      t.decimal :results, precision: 5, scale: 2
      t.decimal :shape, precision: 5, scale: 2
      t.decimal :technical, precision: 5, scale: 2
      t.integer :calibration_management_profession_score
      t.integer :calibration_performance_score
      t.integer :calibration_work_load
      t.integer :calibration_work_attitude
      t.integer :calibration_work_quality
      t.float :manager_scored_total_evaluation_score
      t.float :final_total_evaluation_score
      t.boolean :capability_columns_all_null, default: false, null: false
      t.decimal :planning_interior, precision: 5, scale: 2
      t.decimal :space_creativity, precision: 5, scale: 2
      t.decimal :shape_interior, precision: 5, scale: 2
      t.decimal :graphic_interior_aico, precision: 5, scale: 2
      t.decimal :presentation_interior_aico, precision: 5, scale: 2
      t.decimal :implementation_interior_aico, precision: 5, scale: 2
      t.datetime :deleted_time, null: false

      t.timestamps
    end
  end
end
