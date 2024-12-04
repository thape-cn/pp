module Staff
  class CalibrationSessionUsersController < BaseController
    include UndoCalibrationSessionUser
    after_action :verify_authorized
    before_action :set_calibration_session_user, only: %i[undo_confirm undo]

    def undo_confirm
      @undo_company_evaluation_template = @calibration_session_user
        .calibration_session.calibration_template.company_evaluation_template
      render layout: false
    end

    private

    def set_calibration_session_user
      @calibration_session_user = authorize CalibrationSessionUser.find(params[:id])
    end

    def calibration_session_user_params
      params.require(:calibration_session_user).permit(:undo_calibration_template_id)
    end
  end
end
