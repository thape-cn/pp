require "test_helper"

class CorpPresidentManagedCompanyTest < ActiveSupport::TestCase
  test "User guochunzhong has 2 record of corp_president_managed_companies" do
    guochunzhong = users(:user_guochunzhong)
    assert guochunzhong.valid?
    assert_equal guochunzhong.corp_president_managed_companies.count, 2
  end
end
