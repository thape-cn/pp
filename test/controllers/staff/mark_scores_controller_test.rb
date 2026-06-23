require "test_helper"

class Staff::MarkScoresControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @manager = users(:user_pptest3)
    sign_in @manager
  end

  test "supervisor json can be filtered by mark score group" do
    get staff_mark_score_path(@manager, format: :json), params: {
      company_evaluation_ids: [company_evaluations(:ce_one).id],
      group_level: "supervisor",
      mark_score_group: "4"
    }

    assert_response :success
    response_body = JSON.parse(response.body)
    assert_equal [evaluation_user_capabilities(:euc_supervisor_high).id], response_body.fetch("need_review_evaluations").pluck("id_euc")
    assert_equal [4], response_body.fetch("need_review_evaluations").pluck("mark_score_group").uniq
    assert_equal [4], response_body.fetch("company_evaluation_templates").values.pluck("mark_score_group").uniq
  end

  test "supervisor save response stays filtered by mark score group" do
    euc = evaluation_user_capabilities(:euc_supervisor_high)

    put staff_mark_score_path(@manager, format: :json), params: {
      company_evaluation_ids: [company_evaluations(:ce_one).id],
      group_level: "supervisor",
      mark_score_group: "4",
      mark_score: [{
        id_user: euc.user_id,
        id_cet: euc.company_evaluation_template_id,
        id_euc: euc.id,
        manager_overall_output: euc.manager_overall_output,
        manager_overall_improvement: euc.manager_overall_improvement,
        manager_overall_plan: euc.manager_overall_plan
      }]
    }, as: :json

    assert_response :success
    response_body = JSON.parse(response.body)
    assert_equal [euc.id], response_body.fetch("need_review_evaluations").pluck("id_euc")
    assert_equal [4], response_body.fetch("need_review_evaluations").pluck("mark_score_group").uniq
  end
end
