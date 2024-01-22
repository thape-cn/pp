require "test_helper"

class SecretaryManagedDepartmentTest < ActiveSupport::TestCase
  test "User user_pptest13 has 2 record of hrbp_user_managed_departments" do
    user_pptest13 = users(:user_pptest13)
    assert user_pptest13.valid?
    assert_equal user_pptest13.secretary_managed_departments.count, 2
  end
end
