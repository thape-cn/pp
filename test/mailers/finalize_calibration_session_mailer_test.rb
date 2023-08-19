require "test_helper"

class FinalizeCalibrationSessionMailerTest < ActionMailer::TestCase
  test "notification_manager" do
    mail = FinalizeCalibrationSessionMailer.with(manager: User.first, calibration_session: CalibrationSession.first).notification_manager
    assert_equal "【绩效评价通知】您的下属绩效等级已定案", mail.subject
    assert_equal ["guochunzhong@thape.com.cn"], mail.to
    assert_equal ["performance@thape.com.cn"], mail.from
    assert_match "button-a button-a-primary", mail.body.encoded
  end
end
