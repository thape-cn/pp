require "test_helper"

class CalibrationSessionTest < ActiveSupport::TestCase
  test "resolves the company evaluation template from its evaluation users" do
    calibration_session = calibration_sessions(:cs_one_staff)

    assert_equal company_evaluation_templates(:ect_staff), calibration_session.company_evaluation_template
  end
end
