module Staff
  class CalibrationTableSessionsController < BaseController
    before_action :set_calibration_session, only: %i[show update]
    after_action :verify_authorized

    def show
      return redirect_to staff_root_path, alert: I18n.t("staff.calibration_sessions.show.waiting_score") if @calibration_session.session_status == "waiting_manager_score"
      return redirect_to staff_root_path, alert: I18n.t("staff.calibration_sessions.show.finalized") unless @calibration_session.session_status == "calibrating"
      return redirect_to staff_root_path, alert: I18n.t("staff.calibration_sessions.show.can_not_start") unless @calibration_session.can_start_calibration?

      @group_level = @calibration_session.calibration_template.company_evaluation_template.group_level
      need_calibration_eucs = @calibration_session
        .calibration_session_users.collect(&:evaluation_user_capability)
        .reject(&:blank?) # user must having evaluation_user_capability, even it's only having performance.
      @need_calibration_eucs = EvaluationUserCapability.where(id: need_calibration_eucs.collect(&:id)).order(:id)
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
            expand_tips: I18n.t("evaluation.expand_tips"),
            chinese_name: I18n.t("user.chinese_name"),
            title: I18n.t("user.title"),
            department: I18n.t("user.department"),
            save_tips: I18n.t("staff.calibration_table_sessions.show.save_tips"),
            save: I18n.t("form.save"),
            finalize: I18n.t("form.finalize"),
            row_number: I18n.t("form.row_number"),
            close: I18n.t("form.close")
          }
          @table_headers = calibration_table_headers(@need_calibration_eucs, @group_level)
        end
        format.json do
          @table_headers_of_performance, @job_role_evaluation_performances = prepare_need_review_evaluations(@need_calibration_eucs)
          @company_evaluation_templates = CompanyEvaluationTemplate.where(id: @need_calibration_eucs.collect(&:company_evaluation_template_id).uniq)
        end
      end
    end

    def update
      id_eucs = save_params[:calibration_table_session].collect { |ms| ms[:id_euc] }
      @need_calibration_eucs = EvaluationUserCapability.where(id: id_eucs).order(:id)
      @need_calibration_eucs.each do |euc|
        p = save_params[:calibration_table_session].find { |ms| ms[:id_euc] == euc.id }.to_h
        update_h = p.select { |key, value| !key.start_with?("p_") && value != "none" && !%w[id_cet id_euc id_user raw_total_evaluation_score].include?(key) }
        euc.assign_attributes(update_h)
        euc.save(validate: false)

        company_evaluation_id = CompanyEvaluationTemplate.find(p[:id_cet]).company_evaluation_id
        st_code = JobRole.find(euc.job_role_id).st_code
        job_role_evaluation_performances = JobRoleEvaluationPerformance.where(user_id: p[:id_user])
          .where(company_evaluation_id: company_evaluation_id)
          .where(st_code: st_code)
          .where(dept_code: euc.dept_code)

        performance_h = p.select { |key, value| key.start_with?("p_") && value != "none" }
        job_role_evaluation_performances.each do |jrep|
          next if jrep.obj_result_fixed
          value = performance_h.fetch(jrep.en_name, jrep.obj_result)
          jrep.update(obj_result: value, evaluation_user_capability_id: euc.id)
        end
      end
      @table_headers_of_performance, @job_role_evaluation_performances = prepare_need_review_evaluations(@need_calibration_eucs)
    end

    protected

    def set_page_layout_data
      super
      @_container_class = nil
      @skip_title = true
    end

    private

    def save_params
      params.permit(:id, :format, :group_level,
        calibration_table_session: [:id_user,
          *Capability.performance_column_names,
          :calibration_work_quality, :calibration_work_load, :calibration_work_attitude,
          :calibration_management_profession_score, :calibration_performance_score, :raw_total_evaluation_score,
          :id_cet, :id_euc,
          *Capability.management_column_names, *Capability.profession_column_names,
          *JobRoleEvaluationPerformance.en_column_names],
        company_evaluation_ids: [])
    end

    def set_calibration_session
      @calibration_session = authorize policy_scope(CalibrationSession).find(params[:id])
    end

    def prepare_need_review_evaluations(current_open_evaluations)
      job_role_evaluation_performances = JobRoleEvaluationPerformance.need_review_job_role_evaluation_performance(current_open_evaluations)

      table_headers_of_performance = job_role_evaluation_performances.collect do |jrep|
        {
          Header: jrep.obj_name,
          accessor: jrep.en_name
        }
      end.uniq

      [table_headers_of_performance, job_role_evaluation_performances]
    end

    def calibration_table_headers(current_open_evaluations, group_level)
      job_role_evaluation_performances = JobRoleEvaluationPerformance.need_review_job_role_evaluation_performance(current_open_evaluations)
      table_headers_of_performance = job_role_evaluation_performances.collect do |jrep|
        {
          Header: jrep.obj_name,
          accessor: jrep.en_name
        }
      end.uniq
      table_headers_of_capability = table_need_capabilities(current_open_evaluations).collect do |cap|
        {
          Header: cap.name,
          accessor: cap.en_name # accessor is the "key" in the react table data
        }
      end
      if group_level == "staff"
        staff_table_headers_of_capability_for_calibration(table_headers_of_capability, table_headers_of_performance)
      elsif group_level == "auxiliary"
        manager_table_headers_of_capability_for_calibration(table_headers_of_capability, table_headers_of_performance)
      elsif group_level == "manager_a"
        manager_table_headers_of_capability_for_calibration(table_headers_of_capability, table_headers_of_performance)
      end
    end

    def table_need_capabilities(current_open_evaluations)
      job_role_ids = current_open_evaluations.collect(&:job_role_id).uniq
      evaluation_role_ids = JobRole.where(id: job_role_ids).collect(&:evaluation_role_id).uniq
      capability_ids = EvaluationRoleCapability.where(evaluation_role_id: evaluation_role_ids).collect(&:capability_id).uniq
      Capability.where(id: capability_ids).order(:category_name)
    end

    def staff_table_headers_of_capability_for_calibration(headers_of_capability, headers_of_performance)
      calibration_capability = headers_of_capability.collect do |h|
        accessor = case h[:accessor]
        when "work_load"
          "calibration_work_load"
        when "work_quality"
          "calibration_work_quality"
        when "work_attitude"
          "calibration_work_attitude"
        else
          h[:accessor]
        end
        {Header: h[:Header], accessor: accessor}
      end
      headers_of_performance
        .prepend({Header: I18n.t("calibration.raw_total_evaluation_score"), accessor: "raw_total_evaluation_score"})
        .prepend({Header: I18n.t("calibration.pre_work_attitude"), accessor: "work_attitude"})
        .prepend({Header: I18n.t("calibration.pre_work_quality"), accessor: "work_quality"})
        .prepend({Header: I18n.t("calibration.pre_work_load"), accessor: "work_load"})
        .concat(calibration_capability).append({
          Header: I18n.t("evaluation.total_evaluation_score"),
          accessor: "total_evaluation_score"
        })
    end

    def manager_table_headers_of_capability_for_calibration(headers_of_capability, headers_of_performance)
      calibration_capability = headers_of_capability
      headers_of_performance
        .concat(calibration_capability)
        .append({Header: I18n.t("calibration.raw_total_evaluation_score"),
          accessor: "raw_total_evaluation_score"})
        .append({Header: I18n.t("evaluation.total_evaluation_score"),
          accessor: "total_evaluation_score"})
    end
  end
end
