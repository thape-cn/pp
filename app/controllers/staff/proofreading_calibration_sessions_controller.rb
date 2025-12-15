module Staff
  class ProofreadingCalibrationSessionsController < BaseController
    include Pagy::Backend
    include StaffManagerGroup

    after_action :verify_authorized, except: %i[index expender]
    after_action :verify_policy_scoped, only: :index
    before_action :set_calibration_session, only: %i[show square approve_confirm approve undo_confirm undo]
    before_action :set_breadcrumbs, if: -> { request.format.html? }, only: %i[index show square]

    def index
      add_to_breadcrumbs t(".title"), staff_proofreading_calibration_sessions_path
      @owner_judge_id = params[:owner_judge_id]
      @calibration_user_id = params[:calibration_user_id]
      @session_name = params[:session_name]
      @session_status = params[:session_status]
      calibration_sessions = policy_scope(CalibrationSession)
        .includes(calibration_template: :company_evaluation_template,
          calibration_session_judges: :judge,
          calibration_session_users: [:evaluation_user_capability, :user])
        .where(calibration_template_id: CalibrationTemplate.open_for_user_calibration_template_ids)
      calibration_sessions = if params[:company_evaluation_id].present?
        calibration_sessions
          .where(calibration_templates: {company_evaluation_templates: {company_evaluation_id: params[:company_evaluation_id]}})
      else
        calibration_sessions
      end
      if @owner_judge_id.present?
        calibration_sessions = calibration_sessions.where(owner_id: @owner_judge_id).or(calibration_sessions.where(calibration_session_judges: {judge_id: @owner_judge_id}))
      end
      if @calibration_user_id.present?
        calibration_sessions = calibration_sessions.where(calibration_session_users: {user_id: @calibration_user_id})
      end
      if @session_name.present?
        q = CalibrationSession.sanitize_sql_like(@session_name)
        calibration_sessions = calibration_sessions.where("session_name LIKE ?", "%#{q}%")
      end
      calibration_sessions = calibration_sessions.where(session_status: @session_status) if @session_status.present?
      @pagy, @calibration_sessions = pagy(calibration_sessions, items: current_user.preferred_page_length)
    end

    def show
      add_to_breadcrumbs t("layouts.sidebars.staff.calibration_session"), staff_proofreading_calibration_sessions_path
      add_to_breadcrumbs t(".title")
    end

    def approve_confirm
      render layout: false
    end

    def approve
      return head :no_content unless @calibration_session.session_status == "proofreading"

      @calibration_session.calibration_session_users.each do |csu|
        next if csu.new_calibration_session_id.present?

        csu.evaluation_user_capability.update_form_status_to("hr_review_completed", current_user)
      end
      @calibration_session.update(session_status: "proofreading_completed")
      @calibration_session.calibration_session_users.each do |csu|
        next if csu.new_calibration_session_id.present?

        UploadPpResultJob.perform_async(csu.evaluation_user_capability.id)
      end
      HRReviewCompletedStaffJob.perform_async(@calibration_session.id)
      HRReviewCompletedManagerJob.perform_async(@calibration_session.id)
    end

    def undo_confirm
      render layout: false
    end

    def undo
      @calibration_session.calibration_session_users.each do |csu|
        csu.evaluation_user_capability.update_form_status_to("manager_scored", current_user)
      end
      @calibration_session.update(session_status: "calibrating")
    end

    def square
      add_to_breadcrumbs t("layouts.sidebars.staff.calibration_session"), staff_proofreading_calibration_sessions_path
      add_to_breadcrumbs t("staff.proofreading_calibration_sessions.show.title"), staff_proofreading_calibration_session_path(id: @calibration_session.id)
      add_to_breadcrumbs t(".title")

      group_level = @calibration_session.calibration_template.company_evaluation_template.group_level

      evaluation_user_capabilities = @calibration_session.calibration_session_users.collect(&:evaluation_user_capability)
      @total_people_num = evaluation_user_capabilities.length
      case group_level
      when "staff"
        @evaluation_user_capabilities_group = staff_group(evaluation_user_capabilities)
        render "staff_square"
      when "auxiliary"
        @evaluation_user_capabilities_group = manager_group_a(evaluation_user_capabilities)
        render "auxiliary_square"
      when "manager_a"
        @evaluation_user_capabilities_group = manager_group_a(evaluation_user_capabilities)
        render "manager_a_square"
      when "manager_b"
        @evaluation_user_capabilities_group = manager_group_b(evaluation_user_capabilities)
        render "manager_b_square"
      end
    end

    def expender
      render layout: false
    end

    private

    def set_calibration_session
      @calibration_session = authorize CalibrationSession.find(params[:id])
    end

    def set_breadcrumbs
      @_breadcrumbs = [
        {text: t("layouts.sidebars.staff.header"),
         link: staff_root_path}
      ]
    end
  end
end
