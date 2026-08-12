require "test_helper"

class Admin::CalibrationTemplatesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:user_guochunzhong)
    @company_evaluation = company_evaluations(:ce_one)
    @calibration_template = calibration_templates(:ct_one_staff_nonenforce)
  end

  test "index lists each calibration template once" do
    @calibration_template.company_evaluation_templates << company_evaluation_templates(:ect_supervisor_high)

    get admin_company_evaluation_calibration_templates_path(company_evaluation_id: @company_evaluation.id)

    assert_response :success
    assert_select "tbody tr", count: @company_evaluation.calibration_templates.count
    assert_select "td", text: @calibration_template.template_name, count: 1
  end

  test "new renders the company evaluation template multi-select" do
    get new_admin_company_evaluation_calibration_template_path(company_evaluation_id: @company_evaluation.id)

    assert_response :success
    assert_select "select[name='calibration_template[company_evaluation_template_ids][]'][multiple][required]"
  end

  test "create associates a calibration template to selected evaluation templates" do
    selected_templates = [
      company_evaluation_templates(:ect_staff),
      company_evaluation_templates(:ect_supervisor_high)
    ]
    other_company_evaluation_template = CompanyEvaluationTemplate.create!(
      company_evaluation: company_evaluations(:ce_two),
      title: "Other evaluation template",
      group_level: "staff"
    )

    assert_difference "CalibrationTemplate.count", 1 do
      post admin_company_evaluation_calibration_templates_path(company_evaluation_id: @company_evaluation.id), params: {
        calibration_template: {
          template_name: "Shared calibration template",
          company_evaluation_template_ids: selected_templates.map(&:id) + [other_company_evaluation_template.id]
        }
      }
    end

    calibration_template = CalibrationTemplate.find_by!(template_name: "Shared calibration template")
    assert_equal @company_evaluation, calibration_template.company_evaluation
    assert_equal selected_templates.sort_by(&:id), calibration_template.company_evaluation_templates.sort_by(&:id)
  end

  test "update edits the template and its associations" do
    selected_template = company_evaluation_templates(:ect_supervisor_high)

    put admin_company_evaluation_calibration_template_path(
      id: @calibration_template.id,
      company_evaluation_id: @company_evaluation.id
    ), params: {
      calibration_template: {
        template_name: "Updated shared calibration template",
        company_evaluation_template_ids: [selected_template.id]
      }
    }

    assert_response :no_content
    assert_equal "Updated shared calibration template", @calibration_template.reload.template_name
    assert_equal [selected_template], @calibration_template.company_evaluation_templates
  end
end
