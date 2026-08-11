require "application_system_test_case"
require "warden/test/helpers"

class Staff::MarkScoresTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    @manager = users(:user_pptest3)
    @evaluation = evaluation_user_capabilities(:euc_pp8)
    login_as @manager, scope: :user
  end

  teardown do
    Warden.test_reset!
  end

  test "manager changes an employee score and saves it" do
    visit staff_mark_score_path(
      @manager,
      company_evaluation_ids: [company_evaluations(:ce_one).id],
      locale: "zh-CN"
    )

    within "#staff-mark" do
      employee_row = find("tbody tr", text: @evaluation.user.chinese_name)
      employee_row.find("select[id$='-work_quality']").select("符合标准")

      click_button "保存"
      assert_selector "select[id$='-work_quality'] option:checked", text: "符合标准"
    end

    assert_text "保存成功"
    assert_equal 3, @evaluation.reload.work_quality
  end
end
