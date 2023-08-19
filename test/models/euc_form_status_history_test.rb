require "test_helper"

class EucFormStatusHistoryTest < ActiveSupport::TestCase
  test "euc_form_status_histories one record valid." do
    euc_form_status_history = euc_form_status_histories(:euc_one_form_status_one)
    assert euc_form_status_history.valid?
  end
end
