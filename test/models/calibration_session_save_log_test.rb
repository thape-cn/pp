require "test_helper"

class CalibrationSessionSaveLogTest < ActiveSupport::TestCase
  test "log! captures calibration scores and context" do
    euc = evaluation_user_capabilities(:euc_one)
    euc.update_columns(
      calibration_work_quality: 3,
      calibration_work_load: 5,
      calibration_work_attitude: 1
    )

    log = nil
    assert_difference("CalibrationSessionSaveLog.count", 1) do
      log = CalibrationSessionSaveLog.log!(
        calibration_session: calibration_sessions(:cs_one_staff),
        saved_by: users(:user_pptest10),
        source: "square",
        group_level: "staff",
        eucs: [euc]
      )
    end

    assert log.saved_at.present?
    assert_equal "square", log.source
    assert_equal "staff", log.group_level

    snapshot = log.scores_snapshot.first
    assert_equal euc.id, snapshot["euc_id"]
    assert_equal 3, snapshot["calibration_work_quality"]
    assert_equal 5, snapshot["calibration_work_load"]
    assert_equal 1, snapshot["calibration_work_attitude"]
  end
end
