class CreateCalibrationTemplateCompanyEvaluationTemplates < ActiveRecord::Migration[8.1]
  def up
    create_table :calibration_template_company_evaluation_templates do |t|
      t.references :calibration_template, null: false, foreign_key: true, type: :integer,
        index: {name: "idx_ct_cets_on_calibration_template_id"}
      t.references :company_evaluation_template, null: false, foreign_key: true, type: :integer,
        index: {name: "idx_ct_cets_on_company_evaluation_template_id"}
    end

    add_index :calibration_template_company_evaluation_templates,
      [:calibration_template_id, :company_evaluation_template_id],
      unique: true,
      name: "idx_ct_cets_on_template_ids"

    execute <<~SQL.squish
      INSERT INTO calibration_template_company_evaluation_templates
        (calibration_template_id, company_evaluation_template_id)
      SELECT id, company_evaluation_template_id
      FROM calibration_templates
    SQL

    remove_reference :calibration_templates, :company_evaluation_template,
      null: false, foreign_key: true, type: :integer
  end

  def down
    add_reference :calibration_templates, :company_evaluation_template,
      null: true, foreign_key: true, type: :integer

    execute <<~SQL.squish
      UPDATE calibration_templates
      SET company_evaluation_template_id = (
        SELECT MIN(company_evaluation_template_id)
        FROM calibration_template_company_evaluation_templates
        WHERE calibration_template_id = calibration_templates.id
      )
    SQL

    change_column_null :calibration_templates, :company_evaluation_template_id, false
    drop_table :calibration_template_company_evaluation_templates
  end
end
