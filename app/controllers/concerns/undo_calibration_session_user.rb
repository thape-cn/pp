module UndoCalibrationSessionUser
  extend ActiveSupport::Concern

  def undo
    result = case params["commit"]
    when I18n.t("calibration.to_manager_score")
      @calibration_session_user.evaluation_user_capability.update_form_status_to("self_assessment_done", current_user)
    when I18n.t("calibration.to_department_calibrate")
      @calibration_session_user.evaluation_user_capability.update_form_status_to("manager_scored", current_user)
    end

    undo_user = @calibration_session_user.user
    evaluation_user_capability = @calibration_session_user.evaluation_user_capability
    previous_calibration_session = @calibration_session_user.calibration_session
    undo_calibration_template = CalibrationTemplate.find_by(id: calibration_session_user_params[:undo_calibration_template_id])
    undo_calibration_count = undo_user.calibration_session_users
      .where(evaluation_user_capability_id: evaluation_user_capability.id).count
    if result == true
      new_calibration_session = undo_calibration_template
        .calibration_sessions.find_or_create_by(session_name: "#{undo_calibration_template.template_name}-#{evaluation_user_capability.department}-#{undo_user.chinese_name}-#{undo_calibration_count}", owner_id: previous_calibration_session.owner_id)
      case params["commit"]
      when I18n.t("calibration.to_manager_score")
        new_calibration_session.update(session_status: "waiting_manager_score")
      when I18n.t("calibration.to_department_calibrate")
        if new_calibration_session.can_start_calibration?
          new_calibration_session.update(session_status: "calibrating")
        else
          new_calibration_session.update(session_status: "waiting_manager_score")
        end
      end
      new_calibration_session.calibration_session_users.find_or_create_by(user_id: @calibration_session_user.user.id, evaluation_user_capability_id: evaluation_user_capability.id)
      previous_calibration_session.calibration_session_judges.each do |previous_judge|
        new_calibration_session.calibration_session_judges.find_or_create_by(judge_id: previous_judge.judge_id)
      end
      @calibration_session_user.update(new_calibration_session_id: new_calibration_session.id)
    end
  end
end
