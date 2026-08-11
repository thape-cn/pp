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
    visit_mark_scores

    within "#staff-mark" do
      employee_row = find("tbody tr", text: @evaluation.user.chinese_name)
      employee_row.find("select[id$='-work_quality']").select("符合标准")

      click_button "保存"
      assert_selector "select[id$='-work_quality'] option:checked", text: "符合标准"
    end

    assert_text "保存成功"
    assert_equal 3, @evaluation.reload.work_quality
  end

  test "manager sorts employees and expands a comment row" do
    visit_mark_scores

    within "#staff-mark" do
      initial_names = employee_names
      find("th", text: "姓名").click
      assert_selector "th", text: "姓名 🔼"
      assert_not_equal initial_names, employee_names

      ascending_names = employee_names
      find("th", text: "姓名").click
      assert_selector "th", text: "姓名 🔽"
      assert_equal ascending_names.reverse, employee_names

      employee_row = find("tbody tr", text: @evaluation.user.chinese_name)
      employee_row.all("td")[1].find("span").click
      assert_selector "textarea#manager_overall_output"
    end
  end

  private

  def visit_mark_scores
    visit staff_mark_score_path(
      @manager,
      company_evaluation_ids: [company_evaluations(:ce_one).id],
      locale: "zh-CN"
    )
  end

  def employee_names
    all("tbody > tr").map { |row| row.all("td")[2].text }
  end
end
