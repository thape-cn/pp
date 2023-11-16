module Staff
  class CalibrationSessionsController < BaseController
    include Pagy::Backend
    include StaffManagerGroup
    include UpdateSessionGroup
    before_action :check_brower, only: %i[show], if: -> { request.format.html? }
    after_action :verify_authorized, except: %i[index expender]
    after_action :verify_policy_scoped, only: :index
    before_action :set_calibration_session, only: %i[show update finalize_calibration fixed]
    before_action :set_breadcrumbs, if: -> { request.format.html? }, only: %i[index fixed]

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
            annual_output_pct: I18n.t("evaluation.annual_output_pct"),
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
        update_manager_group(params[:calibration])
      when "manager"
        update_manager_group(params[:calibration])
      end

      if params[:finalize] && @calibration_session.calibration_template.enforce_distribute?
        @enforce_distribute_reject_message = case @group_level
        when "staff"
          check_enforce_distribute_for_staff_group(params[:calibration])
        when "auxiliary"
          check_enforce_distribute_for_staff_group(params[:calibration])
        when "manager"
          check_enforce_distribute_for_manager_group(params[:calibration])
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

    def fixed
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
        manager_group(need_calibration_evaluation_user_capabilities)
      when "manager"
        manager_group(need_calibration_evaluation_user_capabilities)
      end
    end

    def check_enforce_distribute_for_staff_group(calibration)
      lower_quotas_staff = @calibration_session.lower_quotas_staff
      ct = @calibration_session.calibration_template
      apa_grade_rate_people_count = calibration["13"]&.length.to_i + calibration["12"]&.length.to_i + calibration["23"]&.length.to_i
      b_grade_rate_people_count = calibration["11"]&.length.to_i + calibration["22"]&.length.to_i + calibration["33"]&.length.to_i
      cd_grade_rate_people_count = calibration["31"]&.length.to_i + calibration["21"]&.length.to_i + calibration["32"]&.length.to_i
      if lower_quotas_staff[:apa_grade_rate] == apa_grade_rate_people_count \
        && lower_quotas_staff[:b_grade_rate] == b_grade_rate_people_count \
        && lower_quotas_staff[:cd_grade_rate] == cd_grade_rate_people_count
        nil
      else
        I18n.t("calibration.enforce_distribute_for_staff_failure", apa_grade_rate: ct.apa_grade_rate,
          b_grade_rate: ct.b_grade_rate, cd_grade_rate: ct.cd_grade_rate)
      end
    end

    def check_enforce_distribute_for_manager_group(calibration)
      lower_quotas_manager = @calibration_session.lower_quotas_manager
      ct = @calibration_session.calibration_template
      below_standard_rate_people_count = calibration["11"]&.length.to_i + calibration["21"]&.length.to_i + calibration["31"]&.length.to_i
      standards_compliant_rate_people_count = calibration["12"]&.length.to_i + calibration["22"]&.length.to_i + calibration["32"]&.length.to_i
      beyond_standard_rate_people_count = calibration["13"]&.length.to_i + calibration["23"]&.length.to_i + calibration["33"]&.length.to_i
      if lower_quotas_manager[:below_standard_rate] == below_standard_rate_people_count \
        && lower_quotas_manager[:standards_compliant_rate] == standards_compliant_rate_people_count \
        && lower_quotas_manager[:beyond_standard_rate] == beyond_standard_rate_people_count
        nil
      else
        I18n.t("calibration.enforce_distribute_for_manager_failure", below_standard_rate: ct.below_standard_rate,
          standards_compliant_rate: ct.standards_compliant_rate, beyond_standard_rate: ct.beyond_standard_rate)
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
  end
end
