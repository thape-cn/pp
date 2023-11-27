module Admin
  class CalibrationSessionUsersController < BaseController
    include UndoCalibrationSessionUser
    after_action :verify_authorized, except: %i[expender]
    before_action :set_calibration_session_user, only: %i[undo_confirm undo confirm_destroy destroy]

    def expender
      render layout: false
    end

    def undo_confirm
      @undo_company_evaluation_template = @calibration_session_user
        .calibration_session.calibration_template.company_evaluation_template
      render layout: false
    end

    def confirm_destroy
      render layout: false
    end

    def destroy
      @calibration_session_user.destroy
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
