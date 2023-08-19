require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "User guochunzhong has 1 record of euc_form_status_histories" do
    guochunzhong = users(:user_guochunzhong)
    assert guochunzhong.valid?
    assert_equal guochunzhong.euc_form_status_histories.count, 1
  end
end
