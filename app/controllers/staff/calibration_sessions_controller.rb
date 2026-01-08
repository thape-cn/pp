module Staff
  class CalibrationSessionsController < BaseController
    include Pagy::Backend
    include StaffManagerGroup
    include UpdateSessionGroup
    include CheckEnforceDistributeForGroup

    before_action :check_brower, only: %i[show], if: -> { request.format.html? }
    after_action :verify_authorized, except: %i[index expender]
    after_action :verify_policy_scoped, only: :index
    before_action :set_calibration_session, only: %i[show update finalize_calibration square table]
    before_action :set_breadcrumbs, if: -> { request.format.html? }, only: %i[index square table]

    def index
      add_to_breadcrumbs t(".title")
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
      @pagy, @calibration_sessions = pagy(calibration_sessions, items: current_user.preferred_page_length)
      @skip_title = false
    end

    def show
      return redirect_to staff_root_path, alert: I18n.t("staff.calibration_sessions.show.waiting_score") if @calibration_session.session_status == "waiting_manager_score"
      return redirect_to staff_root_path, alert: I18n.t("staff.calibration_sessions.show.finalized") unless @calibration_session.session_status == "calibrating"
      return redirect_to staff_root_path, alert: I18n.t("staff.calibration_sessions.show.can_not_start") unless @calibration_session.can_start_calibration?

      @group_level = @calibration_session.calibration_template.company_evaluation_template.group_level
      respond_to do |format|
        format.html do
          @calibration_labels = {
            self_overall_output: I18n.t("evaluation.self_overall_output"),
            self_overall_improvement: I18n.t("evaluation.self_overall_improvement"),
            self_overall_plan: I18n.t("evaluation.self_overall_plan"),
            manager_overall_output: I18n.t("evaluation.manager_overall_output"),
            manager_overall_improvement: I18n.t("evaluation.manager_overall_improvement"),
            manager_overall_plan: I18n.t("evaluation.manager_overall_plan"),
            nine_square_grid: I18n.t("form.nine_square_grid"),
            table_grid: I18n.t("form.table_grid"),
            work_load_pct: I18n.t("evaluation.work_load_pct"),
            work_quality_pct: I18n.t("evaluation.work_quality_pct"),
            work_attitude_pct: I18n.t("evaluation.work_attitude_pct"),
            annual_output_pct: I18n.t("evaluation.annual_output_pct"), # it used at {calibrationLabels()[`${key}_pct`]}
            below_standard: I18n.t("evaluation.below_standard"),
            standards_compliant: I18n.t("evaluation.standards_compliant"),
            beyond_standard: I18n.t("evaluation.beyond_standard"),
            fixed_output: I18n.t("evaluation.fixed_output"),
            professional_capability: I18n.t("evaluation.professional_capability"),
            management_capability: I18n.t("evaluation.management_capability"),
            capability_result: I18n.t("evaluation.capability_result"),
            performance: I18n.t("evaluation.performance"),
            obj_result: I18n.t("evaluation.obj_result"),
            encourage: I18n.t("calibration.encourage"),
            enforce: I18n.t("calibration.enforce"),
            current_people: I18n.t("calibration.current_people"),
            total_evaluation_score: I18n.t("evaluation.total_evaluation_score"),
            save: I18n.t("form.save"),
            finalize: I18n.t("form.finalize"),
            accept_title: I18n.t("calibration.accept_title"),
            enforce_distribute_title: I18n.t("calibration.enforce_distribute_title"),
            close: I18n.t("form.close")
          }
        end
        format.json do
          @need_calibration_evaluation_user_capabilities = need_calibration_euc_by_group(@calibration_session, @group_level)
          having_data_keys = @need_calibration_evaluation_user_capabilities.keys
          @blank_data_keys = %w[11 12 13 21 22 23 31 32 33] - having_data_keys
        end
      end
      @skip_title = true
    end

    def update
      @group_level = params[:group_level]

      case @group_level
      when "staff"
        update_staff_group(params[:calibration])
      when "auxiliary"
        update_manager_group_a(params[:calibration])
      when "manager_a"
        update_manager_group_a(params[:calibration])
      when "manager_b"
        update_manager_group_b(params[:calibration])
      end

      log_calibration_session_save(
        source: "square",
        group_level: @group_level,
        euc_ids: calibration_euc_ids_from_square(params[:calibration])
      )

      if params[:finalize] && @calibration_session.calibration_template.enforce_distribute?
        @enforce_distribute_reject_message = case @group_level
        when "staff"
          check_enforce_distribute_for_aa_b_cd_group(params[:calibration], @calibration_session.calibration_template.enforce_highest_only?)
        when "auxiliary"
          check_enforce_distribute_for_aa_b_cd_group(params[:calibration], @calibration_session.calibration_template.enforce_highest_only?)
        when "manager_a"
          check_enforce_distribute_for_manager_group(params[:calibration], @calibration_session.calibration_template.enforce_highest_only?)
        when "manager_b"
          check_enforce_distribute_for_aa_b_cd_group(params[:calibration], @calibration_session.calibration_template.enforce_highest_only?)
        end
        if @enforce_distribute_reject_message.nil?
          @accept_finalize_confirm_message = I18n.t("calibration.accept_finalize_confirm_message")
        end
      elsif params[:finalize] # not a enforce_distribute
        @accept_finalize_confirm_message = I18n.t("calibration.accept_finalize_confirm_message")
      else
        @accept_finalize_confirm_message = I18n.t("evaluation.update_success")
      end

      @need_calibration_evaluation_user_capabilities = need_calibration_euc_by_group(@calibration_session, @group_level)
      having_data_keys = @need_calibration_evaluation_user_capabilities.keys
      @blank_data_keys = %w[11 12 13 21 22 23 31 32 33] - having_data_keys
    end

    def finalize_calibration
      @calibration_session.calibration_session_users.each do |csu|
        evaluation_user_capability = csu.evaluation_user_capability
        evaluation_user_capability.update_form_status_to("department_calibrated", current_user)
        evaluation_user_capability.update_columns(final_total_evaluation_score: evaluation_user_capability.total_evaluation_score)
      end
      @calibration_session.update(session_status: "proofreading")
    end

    def square
      add_to_breadcrumbs t("layouts.sidebars.staff.calibration_session"), staff_calibration_sessions_path
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

    def table
      add_to_breadcrumbs t("layouts.sidebars.staff.calibration_session"), staff_calibration_sessions_path
      add_to_breadcrumbs t(".title")
    end

    def expender
      render layout: false
    end

    protected

    def set_page_layout_data
      super
      @_container_class = nil
    end

    private

    def need_calibration_euc_by_group(calibration_session, group_level)
      need_calibration_evaluation_user_capabilities = calibration_session
        .calibration_session_users.collect(&:evaluation_user_capability)
        .reject(&:blank?) # user must having evaluation_user_capability, even it's only having performance.
      case group_level
      when "staff"
        staff_group(need_calibration_evaluation_user_capabilities)
      when "auxiliary"
        manager_group_a(need_calibration_evaluation_user_capabilities)
      when "manager_a"
        manager_group_a(need_calibration_evaluation_user_capabilities)
      when "manager_b"
        manager_group_b(need_calibration_evaluation_user_capabilities)
      end
    end

    def set_calibration_session
      @calibration_session = authorize policy_scope(CalibrationSession).find(params[:id])
    end

    def set_breadcrumbs
      @_breadcrumbs = [
        {text: t("layouts.sidebars.staff.header"),
         link: root_path}
      ]
    end

    def log_calibration_session_save(source:, group_level:, euc_ids:)
      return if euc_ids.blank?

      eucs = EvaluationUserCapability.where(id: euc_ids)
      return if eucs.blank?

      CalibrationSessionSaveLog.log!(
        calibration_session: @calibration_session,
        saved_by: current_user,
        source: source,
        group_level: group_level,
        eucs: eucs
      )
    end

    def calibration_euc_ids_from_square(calibration_params)
      return [] if calibration_params.blank?

      calibration_params.values.flat_map do |square|
        Array(square).map { |item| item["id"] || item[:id] }
      end.compact.uniq
    end
  end
end
