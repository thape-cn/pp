require "test_helper"

class HrbpUserManagedDepartmentTest < ActiveSupport::TestCase
  test "User guochunzhong has 2 record of hrbp_user_managed_departments" do
    guochunzhong = users(:user_guochunzhong)
    assert guochunzhong.valid?
    assert_equal guochunzhong.hrbp_user_managed_departments.count, 2
  end
end
