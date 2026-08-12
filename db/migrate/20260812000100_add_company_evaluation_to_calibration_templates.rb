class AddCompanyEvaluationToCalibrationTemplates < ActiveRecord::Migration[8.1]
  def up
    add_reference :calibration_templates, :company_evaluation,
      null: true, foreign_key: true, type: :integer

    conflicting_template_ids = select_values <<~SQL.squish
      SELECT calibration_templates.id
      FROM calibration_templates
      INNER JOIN calibration_template_company_evaluation_templates
        ON calibration_template_company_evaluation_templates.calibration_template_id = calibration_templates.id
      INNER JOIN company_evaluation_templates
        ON company_evaluation_templates.id = calibration_template_company_evaluation_templates.company_evaluation_template_id
      GROUP BY calibration_templates.id
      HAVING COUNT(DISTINCT company_evaluation_templates.company_evaluation_id) > 1
    SQL

    if conflicting_template_ids.any?
      raise ActiveRecord::MigrationError,
        "Calibration templates are linked across company evaluations: #{conflicting_template_ids.join(", ")}"
    end

    execute <<~SQL.squish
      UPDATE calibration_templates
      SET company_evaluation_id = (
        SELECT MIN(company_evaluation_templates.company_evaluation_id)
        FROM calibration_template_company_evaluation_templates
        INNER JOIN company_evaluation_templates
          ON company_evaluation_templates.id = calibration_template_company_evaluation_templates.company_evaluation_template_id
        WHERE calibration_template_company_evaluation_templates.calibration_template_id = calibration_templates.id
      )
    SQL

    templates_without_company_evaluation = select_value <<~SQL.squish
      SELECT COUNT(*)
      FROM calibration_templates
      WHERE company_evaluation_id IS NULL
    SQL

    if templates_without_company_evaluation.to_i.positive?
      raise ActiveRecord::MigrationError,
        "Every calibration template must be linked to a company evaluation template before this migration"
    end

    change_column_null :calibration_templates, :company_evaluation_id, false
  end

  def down
    remove_reference :calibration_templates, :company_evaluation,
      foreign_key: true, type: :integer
  end
end
