require "test_helper"

class Staff::MarkScoresControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @manager = users(:user_pptest3)
    sign_in @manager
  end

  test "supervisor html exposes table headers per mark score group" do
    supervisor_capability_headers = [
      ["detail_design", "深化设计"],
      ["master_planning", "总图"],
      ["complex_chassis_design", "复杂底盘"],
      ["facade_design", "立面"],
      ["product_design", "产品"],
      ["project_management_coordination", "项目管理及协调"]
    ].collect do |en_name, name|
      capability = Capability.create!(
        en_name: en_name,
        name: name,
        description: nil,
        category_name: "专业能力"
      )
      EvaluationRoleCapability.create!(
        evaluation_role: evaluation_roles(:er_technical_director),
        capability: capability
      )
      en_name
    end

    get staff_mark_score_path(@manager), params: {
      company_evaluation_ids: [company_evaluations(:ce_one).id]
    }

    assert_response :success
    supervisor_node = css_select("#supervisor-mark").first
    groups = JSON.parse(supervisor_node["data-mark-score-groups"])
    high_group_accessors = groups.find { |group| group.fetch("value") == 4 }.fetch("table_header").pluck("accessor")
    mid_group_accessors = groups.find { |group| group.fetch("value") == 3 }.fetch("table_header").pluck("accessor")

    assert_includes high_group_accessors, "p_managedproject_output"
    assert_includes high_group_accessors, "p_managedproject_profit"
    assert_equal [
      "complex_chassis_design",
      "facade_design",
      "detail_design",
      "product_design",
      "master_planning",
      "project_management_coordination"
    ], high_group_accessors & supervisor_capability_headers
    assert_includes mid_group_accessors, "p_individual_hours"
    assert_includes mid_group_accessors, "p_individual_output"
    assert_not_includes mid_group_accessors, "p_managedproject_output"
    assert_not_includes mid_group_accessors, "p_managedproject_profit"
  end

  test "supervisor json can be filtered by mark score group" do
    job_role_evaluation_performances(:jrep_supervisor_high_individual_hours)
      .update!(obj_result_explain: "behind target")
    job_role_evaluation_performances(:jrep_supervisor_high_individual_output)
      .update!(obj_result_explain: "output explanation")

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
    assert_equal "behind target", response_body.fetch("need_review_evaluations").first.fetch("p_individual_hours_obj_result_explain")
    assert_equal "output explanation", response_body.fetch("need_review_evaluations").first.fetch("p_individual_output_obj_result_explain")
  end

  test "supervisor json tolerates shared capability header missing from one role" do
    EvaluationRoleCapability.create!(
      evaluation_role: evaluation_roles(:er_functional_lead),
      capability: capabilities(:capable_work_load),
      erc_description: "lead work load description"
    )
    EvaluationUserCapability.create!(
      company_evaluation_template: company_evaluation_templates(:ect_supervisor_high),
      user: users(:user_pptest2),
      job_role: job_roles(:job_76),
      manager_user: @manager,
      company: "测试公司",
      department: "测试组织",
      dept_code: "000001",
      title: "资深建筑师（方案）",
      self_overall_output: "资深建筑师（方案） self_overall_output 1234567890",
      self_overall_improvement: "资深建筑师（方案） self_overall_improvement 1234567890",
      self_overall_plan: "资深建筑师（方案） self_overall_plan 1234567890",
      manager_overall_output: "资深建筑师（方案） manager_overall_output 1234567890",
      manager_overall_improvement: "资深建筑师（方案） manager_overall_improvement 1234567890",
      manager_overall_plan: "资深建筑师（方案） manager_overall_plan 1234567890",
      form_status: "self_assessment_done",
      work_load: 1,
      work_quality: 1,
      work_attitude: 1
    )
    EvaluationUserCapability.create!(
      company_evaluation_template: company_evaluation_templates(:ect_supervisor_high),
      user: users(:user_pptest4),
      job_role: job_roles(:job_82),
      manager_user: @manager,
      company: "测试公司",
      department: "测试组织",
      dept_code: "000001",
      title: "助理主创建筑师",
      self_overall_output: "助理主创建筑师 self_overall_output 1234567890",
      self_overall_improvement: "助理主创建筑师 self_overall_improvement 1234567890",
      self_overall_plan: "助理主创建筑师 self_overall_plan 1234567890",
      manager_overall_output: "助理主创建筑师 manager_overall_output 1234567890",
      manager_overall_improvement: "助理主创建筑师 manager_overall_improvement 1234567890",
      manager_overall_plan: "助理主创建筑师 manager_overall_plan 1234567890",
      form_status: "self_assessment_done",
      work_load: 1,
      work_quality: 1,
      work_attitude: 1
    )

    get staff_mark_score_path(@manager, format: :json), params: {
      company_evaluation_ids: [company_evaluations(:ce_one).id],
      group_level: "supervisor",
      mark_score_group: "4"
    }

    assert_response :success
    response_body = JSON.parse(response.body)
    high_role_row = response_body.fetch("need_review_evaluations").find do |row|
      row.fetch("id_euc") == evaluation_user_capabilities(:euc_supervisor_high).id
    end
    functional_row = response_body.fetch("need_review_evaluations").find do |row|
      row.fetch("title") == "资深建筑师（方案）"
    end

    assert_not high_role_row.key?("work_load_ercd")
    assert_includes functional_row.fetch("work_load_ercd"), "日常工作及上级布置的其他工作任务"
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

  test "score confirm returns mark scores path when reviews remain" do
    euc = evaluation_user_capabilities(:euc_supervisor_high)
    company_evaluation_ids = [company_evaluations(:ce_one).id]

    put score_confirm_staff_mark_score_path(@manager, format: :json), params: {
      euc_ids: [euc.id],
      company_evaluation_ids: company_evaluation_ids
    }, as: :json

    assert_response :success
    assert_equal staff_mark_score_path(id: @manager.id, company_evaluation_ids: company_evaluation_ids),
      JSON.parse(response.body).fetch("go_path")
  end

  test "score confirm returns staff root when no reviews remain" do
    company_evaluation_ids = [company_evaluations(:ce_one).id]
    remaining_reviews = EvaluationUserCapability
      .joins(:company_evaluation_template)
      .where(company_evaluation_template: {company_evaluation_id: company_evaluation_ids})
      .where(manager_user_id: @manager.id, form_status: "self_assessment_done")
    euc = remaining_reviews.first
    remaining_reviews.where.not(id: euc.id).update_all(form_status: "manager_scored")

    put score_confirm_staff_mark_score_path(@manager, format: :json), params: {
      euc_ids: [euc.id],
      company_evaluation_ids: company_evaluation_ids
    }, as: :json

    assert_response :success
    assert_equal staff_root_path, JSON.parse(response.body).fetch("go_path")
  end
end
