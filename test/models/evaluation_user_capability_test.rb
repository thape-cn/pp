require "test_helper"

class EvaluationUserCapabilityTest < ActiveSupport::TestCase
  test "EvaluationUserCapability one has 1 record of euc_form_status_histories" do
    euc_one = evaluation_user_capabilities(:euc_one)
    assert euc_one.valid?
    assert_equal euc_one.euc_form_status_histories.count, 2
  end
end
