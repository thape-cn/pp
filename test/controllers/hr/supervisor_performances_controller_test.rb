require "test_helper"

class HR::SupervisorPerformancesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:user_guochunzhong)
    @evaluation = evaluation_user_capabilities(:euc_supervisor_high)
  end

  test "details map original and calibrated work attitude using the configured metric" do
    [
      ["grading_3_metric", 3, 5, "符合标准", "超出标准"],
      ["grading_5_metric", 4, 1, "A", "D"],
      ["grading_9_metric", 4.5, 3, "4.5", "3-合格"]
    ].each do |metric, original_score, calibrated_score, original_label, calibrated_label|
      @evaluation.company_evaluation_template.update!(work_attitude_metric: metric)
      @evaluation.update!(work_attitude: original_score, calibration_work_attitude: calibrated_score)

      get hr_supervisor_performance_path(@evaluation, locale: "zh-CN")

      assert_response :success
      assert_card_text "工作态度", original_label
      assert_card_text "校准后的工作态度", calibrated_label
      assert_card_text "工作量", "低于标准"
      assert_card_text "工作质量", "低于标准"
    end
  end

  test "details preserve unmapped work attitude scores" do
    @evaluation.update!(work_attitude: 0, calibration_work_attitude: 0)

    get hr_supervisor_performance_path(@evaluation, locale: "zh-CN")

    assert_response :success
    assert_card_text "工作态度", "0.0"
    assert_card_text "校准后的工作态度", "0"
  end

  private

  def assert_card_text(title, text)
    assert_select ".card", count: 1, text: /\A\s*#{Regexp.escape(title)}\s+#{Regexp.escape(text)}\s*\z/
  end
end
