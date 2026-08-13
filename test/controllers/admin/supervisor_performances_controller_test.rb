require "test_helper"

module Admin
  class SupervisorPerformancesControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test "department filter is a Selectize multi-select" do
      sign_in users(:user_guochunzhong)
      evaluation_user_capabilities(:euc_supervisor_high).update!(department: "设计一所")
      evaluation_user_capabilities(:euc_supervisor_mid).update!(department: "设计二所")

      get admin_supervisor_performances_url, params: {
        company_evaluation_id: company_evaluations(:ce_one).id,
        company: "测试公司",
        department: ["设计一所", "设计二所"],
        form_status: "self_assessment_done"
      }

      assert_response :success
      assert_select "script[src*='selectize']"
      assert_select ".col-3[data-controller='selectizes'] select#department[multiple][name='department[]'][data-selectizes-target='select']" do
        assert_select "option[selected]", count: 2
        assert_select "option[value='设计一所'][selected]"
        assert_select "option[value='设计二所'][selected]"
      end
      assert_includes response.body, users(:user_pptest1).chinese_name
      assert_includes response.body, users(:user_pptest2).chinese_name
    end
  end
end
