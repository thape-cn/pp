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

  test "manager sorts employees and saves an expanded comment row" do
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
      assert_field "manager_overall_output", with: @evaluation.manager_overall_output
      # Reorder while the comment is open; it must move with its employee.
      2.times do
        find("th", text: "姓名").click
        employee_row = find("tbody > tr", text: @evaluation.user.chinese_name)
        comment_row = employee_row.find(:xpath, "following-sibling::tr[1]")
        within comment_row do
          assert_field "manager_overall_output", with: @evaluation.manager_overall_output
        end
        assert_equal all("thead th").length.to_s, comment_row.find("td")["colspan"]
      end
      fill_in "manager_overall_output", with: "Updated manager output after sorting"
      click_button "保存评论并关闭"
      assert_no_selector "textarea#manager_overall_output"
    end

    assert_equal "Updated manager output after sorting", @evaluation.reload.manager_overall_output
  end

  test "numeric and raw total sorting keep edits attached to the employee" do
    @evaluation.update!(work_quality: 5, work_load: 5, work_attitude: 5)
    other = evaluation_user_capabilities(:euc_pp4)
    other.update!(work_quality: 1, work_load: 3, work_attitude: 1)
    company_evaluation_templates(:ect_staff).update!(work_load_metric: "grading_9_metric")
    @evaluation.update!(work_load: 4)
    assert_equal 4.5, @evaluation.raw_total_evaluation_score
    assert_equal 2.0, other.raw_total_evaluation_score
    visit_mark_scores

    headers = JSON.parse(find("#staff-mark")["data-header"])
    within "#staff-mark" do
      %w[work_quality raw_total_evaluation_score_raw].each do |accessor|
        index = headers.index { |header| header["accessor"] == accessor } + 5
        all("thead th")[index].click
        assert_selector "thead th[aria-sort='ascending']"
        names = employee_names
        assert_operator names.index(other.user.chinese_name), :<, names.index(@evaluation.user.chinese_name)
        all("thead th")[index].click
        assert_selector "thead th[aria-sort='descending']"
        names = employee_names
        assert_operator names.index(@evaluation.user.chinese_name), :<, names.index(other.user.chinese_name)
      end

      employee_row = find("tbody tr", text: @evaluation.user.chinese_name)
      employee_row.find("select[id$='-work_quality']").select("符合标准")
      2.times do
        find("tbody tr", text: @evaluation.user.chinese_name).all("td")[1].find("span").click
        assert_field "manager_overall_output"
        find("tbody tr", text: @evaluation.user.chinese_name).all("td")[1].find("span").click
        assert_no_selector "textarea#manager_overall_output"
      end
      click_button "保存", exact: true
    end
    assert_text "保存成功"
    assert_equal 3, @evaluation.reload.work_quality
    assert_equal 1, other.reload.work_quality
    within "#staff-mark" do
      total_index = headers.index { |header| header["accessor"] == "raw_total_evaluation_score_raw" } + 5
      row = find("tbody tr", text: @evaluation.user.chinese_name)
      assert_equal @evaluation.raw_total_evaluation_score.round(2).to_s.delete_suffix(".0"), row.all("td")[total_index].text
    end
    visit_mark_scores
    within "#staff-mark" do
      assert_selector "tbody tr", text: @evaluation.user.chinese_name
      assert_equal "3", find("tbody tr", text: @evaluation.user.chinese_name).find("select[id$='-work_quality']").value
    end
  end

  test "confirmation requires saving and displays incomplete score feedback" do
    visit_mark_scores
    within "#staff-mark" do
      assert_button "确定并提交", disabled: true
      click_button "保存", exact: true
      assert_button "确定并提交", disabled: false
      find("tbody tr", text: @evaluation.user.chinese_name).find("select[id$='-work_quality']").select("符合标准")
      assert_button "确定并提交", disabled: true
      click_button "保存", exact: true
      assert_button "确定并提交", disabled: false
      click_button "确定并提交"
    end
    within "#coreuiModal" do
      assert_selector ".modal-title", text: I18n.t("evaluation.reject_title", locale: "zh-CN")
      assert_no_button "提交", exact: true
      assert_text @evaluation.user.chinese_name
    end
    assert_equal "self_assessment_done", @evaluation.reload.form_status
  end

  test "supervisor groups keep dynamic columns and saved state independent" do
    high = evaluation_user_capabilities(:euc_supervisor_high)
    mid = evaluation_user_capabilities(:euc_supervisor_mid)
    mid.update!(coaching: 5)
    visit_mark_scores
    assert_selector "#supervisor-mark section", count: 2
    groups = JSON.parse(find("#supervisor-mark")["data-mark-score-groups"])
    groups.each_with_index do |group, index|
      within all("#supervisor-mark section")[index] do
        assert_selector "thead th", count: group.fetch("table_header").length + 5
        group.fetch("table_header").each do |header|
          assert_selector "th", text: header.fetch("Header")
        end
      end
    end
    high_section = find("#supervisor-mark section", text: high.user.chinese_name)
    mid_section = find("#supervisor-mark section", text: mid.user.chinese_name)
    within high_section do
      find("select[id$='-coaching']").select("符合标准")
      click_button "保存", exact: true
      assert_button "确定并提交", disabled: false
    end
    within mid_section do
      assert_button "确定并提交", disabled: true
      assert_equal "5", find("select[id$='-coaching']").value
    end
    assert_equal 3, high.reload.coaching
    assert_equal 5, mid.reload.coaching
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
