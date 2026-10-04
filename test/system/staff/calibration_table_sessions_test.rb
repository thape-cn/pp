require "application_system_test_case"
require "warden/test/helpers"

class Staff::CalibrationTableSessionsTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    @calibration_session = calibration_sessions(:cs_one_staff)
    @evaluation = evaluation_user_capabilities(:euc_pp11)
    @evaluation.update!(form_status: "manager_scored")
    @calibration_session.update!(session_status: "calibrating")
    login_as @calibration_session.owner, scope: :user
  end

  teardown do
    Warden.test_reset!
  end

  test "calibration owner expands an employee comment row" do
    visit staff_calibration_table_session_path(@calibration_session, locale: "zh-CN")

    within "#calibration-table" do
      employee_row = find("tbody tr", text: @evaluation.user.chinese_name)
      employee_row.all("td")[1].find("span").click

      assert_selector "tbody > tr", count: 2
      assert_text @evaluation.self_overall_output
    end
  end

  test "read only calibration scores persist when switching to the grid" do
    @evaluation.update!(calibration_work_quality: 3)
    visit staff_calibration_table_session_path(@calibration_session, locale: "zh-CN")
    within "#calibration-table" do
      row = find("tbody tr", text: @evaluation.user.chinese_name)
      assert_no_selector "select"
      assert_text "符合标准"
      find("th", text: "姓名").click
      row.all("td")[1].find("span").click
      assert_text @evaluation.self_overall_output
    end
    click_button "九宫格"
    assert_current_path staff_calibration_session_path(@calibration_session), ignore_query: true
    assert_equal 3, @evaluation.reload.calibration_work_quality
    visit staff_calibration_table_session_path(@calibration_session, locale: "zh-CN")
    within "#calibration-table" do
      assert_text "符合标准"
      assert_no_selector "select"
    end
  end

  test "sorting two employees keeps the expanded review with its owner" do
    other = evaluation_user_capabilities(:euc_pp8)
    other.update!(form_status: "manager_scored")
    CalibrationSessionUser.create!(calibration_session: @calibration_session,
      user: other.user, evaluation_user_capability: other)
    visit staff_calibration_table_session_path(@calibration_session, locale: "zh-CN")

    within "#calibration-table" do
      assert_selector "tbody > tr", count: 2
      find("tbody > tr", text: @evaluation.user.chinese_name).all("td")[1].find("span").click
      assert_text @evaluation.self_overall_output
      find("th", text: "姓名").click
      assert_selector "th[aria-sort='ascending']", text: "姓名"
      ascending = all("tbody > tr").select { |row| row.all("td").length > 1 }.map { |row| row.all("td")[2].text }
      find("th", text: "姓名").click
      assert_selector "th[aria-sort='descending']", text: "姓名"
      descending = all("tbody > tr").select { |row| row.all("td").length > 1 }.map { |row| row.all("td")[2].text }
      assert_equal ascending.reverse, descending
      comment_row = find("tbody > tr", text: @evaluation.user.chinese_name).find(:xpath, "following-sibling::tr[1]")
      assert_equal all("thead th").length.to_s, comment_row.find("td")["colspan"]
      within comment_row do
        assert_text @evaluation.self_overall_output
      end
      find("tbody > tr", text: @evaluation.user.chinese_name).all("td")[1].find("span").click
      assert_selector "tbody > tr", count: 2
    end
  end
end
