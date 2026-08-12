require "test_helper"

class Admin::EvaluationTemplatesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:user_guochunzhong)
    @company_evaluation = company_evaluations(:ce_one)
    @company_evaluation_template = company_evaluation_templates(:ect_staff)
  end

  test "index links to dedicated calibration templates page without nested calibration rows" do
    get admin_company_evaluation_templates_path(company_evaluation_id: @company_evaluation.id)

    assert_response :success
    assert_select "a[href='#{admin_company_evaluation_calibration_templates_path(company_evaluation_id: @company_evaluation.id)}']"
    assert_select "tbody tr", count: @company_evaluation.company_evaluation_templates.count
  end

  test "edit renders a calibration template multi-select" do
    get edit_admin_company_evaluation_template_path(
      id: @company_evaluation_template.id,
      company_evaluation_id: @company_evaluation.id
    )

    assert_response :success
    assert_select "select[name='company_evaluation_template[calibration_template_ids][]'][multiple]"
  end

  test "update replaces calibration template associations" do
    calibration_template = calibration_templates(:ct_two_auxiliary_nonenforce)

    put admin_company_evaluation_template_path(
      id: @company_evaluation_template.id,
      company_evaluation_id: @company_evaluation.id
    ), params: {
      company_evaluation_template: {
        title: @company_evaluation_template.title,
        calibration_template_ids: [calibration_template.id]
      }
    }

    assert_response :no_content
    assert_equal [calibration_template], @company_evaluation_template.calibration_templates.reload
  end

  test "update ignores a calibration template from another company evaluation" do
    other_company_evaluation_template = CompanyEvaluationTemplate.create!(
      company_evaluation: company_evaluations(:ce_two),
      title: "Other evaluation template",
      group_level: "staff"
    )
    other_calibration_template = CalibrationTemplate.create!(
      company_evaluation: company_evaluations(:ce_two),
      company_evaluation_templates: [other_company_evaluation_template],
      template_name: "Other calibration template"
    )

    put admin_company_evaluation_template_path(
      id: @company_evaluation_template.id,
      company_evaluation_id: @company_evaluation.id
    ), params: {
      company_evaluation_template: {
        title: @company_evaluation_template.title,
        calibration_template_ids: [other_calibration_template.id]
      }
    }

    assert_response :no_content
    assert_empty @company_evaluation_template.calibration_templates.reload
  end
end
