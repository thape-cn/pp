module Staff
  class MarkScoresController < BaseController
    before_action :check_brower, only: %i[show], if: -> { request.format.html? }
    after_action :verify_authorized

    def show
      manager = authorize(policy_scope(User).find(params[:id]), :show_mark_scores?)
      current_open_evaluations = policy_scope(EvaluationUserCapability)
        .joins(:company_evaluation_template)
        .where(company_evaluation_template: {company_evaluation_id: params[:company_evaluation_ids]})
        .where(manager_user_id: manager.id)
        .where(form_status: %w[self_assessment_done])
      respond_to do |format|
        format.html do
          @staff_table_headers = table_headers(current_open_evaluations, "staff")
          @manager_table_headers = table_headers(current_open_evaluations, "manager")
          @review_labels = {
            self_overall_output: I18n.t("evaluation.self_overall_output"),
            self_overall_improvement: I18n.t("evaluation.self_overall_improvement"),
            self_overall_plan: I18n.t("evaluation.self_overall_plan"),
            manager_overall_output: I18n.t("evaluation.manager_overall_output"),
            manager_overall_improvement: I18n.t("evaluation.manager_overall_improvement"),
            manager_overall_plan: I18n.t("evaluation.manager_overall_plan"),
            expand_tips: I18n.t("evaluation.expand_tips"),
            chinese_name: I18n.t("user.chinese_name"),
            title: I18n.t("user.title"),
            department: I18n.t("user.department"),
            comment: I18n.t("evaluation.comment"),
            save: I18n.t("form.save"),
            save_comment: I18n.t("form.save_comment"),
            save_comment_close: I18n.t("form.save_comment_close"),
            save_and_confirm: I18n.t("form.save_and_confirm"),
            save_and_confirm_tips: I18n.t("staff.mark_scores.show.save_and_confirm_tips"),
            accept_title: I18n.t("evaluation.accept_title"),
            reject_title: I18n.t("evaluation.reject_title"),
            not_rated: I18n.t("evaluation.not_rated"),
            submit: I18n.t("form.submit"),
            row_number: I18n.t("form.row_number"),
            close: I18n.t("form.close")
          }
        end
        format.json do
          group_level = params[:group_level]
          @need_review_evaluations = current_open_evaluations
            .where(company_evaluation_template: {group_level: group_level})
          @job_role_evaluation_performances = JobRoleEvaluationPerformance.need_review_job_role_evaluation_performance(@need_review_evaluations)
          @table_headers_of_performance = prepare_table_headers_of_performance(@job_role_evaluation_performances)
          @company_evaluation_templates = CompanyEvaluationTemplate.where(id: @need_review_evaluations.collect(&:company_evaluation_template_id).uniq)
        end
      end
    end

    def update
      manager = authorize(policy_scope(User).find(params[:id]), :mark_scores?)
      need_update_evaluations = policy_scope(EvaluationUserCapability).where(id: save_params[:mark_score].collect { |ms| ms[:id_euc] })
      need_update_evaluations.each do |euc|
        p = save_params[:mark_score].find { |ms| ms[:id_euc] == euc.id }.to_h
        update_h = p.select { |key, value| !key.start_with?("p_") && value != "none" && key != "id_cet" && key != "id_euc" && key != "id_user" }
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
      current_open_evaluations = policy_scope(EvaluationUserCapability)
        .joins(:company_evaluation_template)
        .where(company_evaluation_template: {company_evaluation_id: params[:company_evaluation_ids]})
        .where(manager_user_id: manager.id)
      group_level = params[:group_level]
      @need_review_evaluations = current_open_evaluations
        .where(company_evaluation_template: {group_level: group_level})
        .where(form_status: %w[self_assessment_done])
      @job_role_evaluation_performances = JobRoleEvaluationPerformance.need_review_job_role_evaluation_performance(@need_review_evaluations)
      if params[:confirm]
        @mark_score_confirm_reject_message = check_mark_score_completion(@need_review_evaluations, @job_role_evaluation_performances)
        if @mark_score_confirm_reject_message.blank?
          @accept_mark_score_confirm_message = I18n.t("evaluation.accept_mark_score_confirm_message")
        end
      else
        @accept_mark_score_confirm_message = I18n.t("evaluation.update_success")
      end
      @table_headers_of_performance = prepare_table_headers_of_performance(@job_role_evaluation_performances)
    end

    def score_confirm
      authorize(policy_scope(User).find(params[:id]), :score_confirm?)
      evaluation_user_capabilities = policy_scope(EvaluationUserCapability).where(id: params[:euc_ids])
      evaluation_user_capabilities.each do |evaluation_user_capability|
        evaluation_user_capability.update_form_status_to("manager_scored", current_user)
        evaluation_user_capability.update_columns(
          manager_scored_total_evaluation_score: evaluation_user_capability.pre_total_evaluation_score,
          final_total_evaluation_score: evaluation_user_capability.total_evaluation_score
        )
      end

      new_calibration_session_ids = evaluation_user_capabilities.collect do |euc|
        next if euc.calibration_session_user.blank?
        euc.calibration_session_user.new_calibration_session_id
      end.reject(&:blank?)

      original_calibration_session_ids = evaluation_user_capabilities.collect do |euc|
        next if euc.calibration_session_user.blank?
        next if euc.calibration_session_user.new_calibration_session_id.present?
        euc.calibration_session_user.calibration_session_id
      end.reject(&:blank?)

      owner_calibrating_reminder = OwnerCalibratingReminder.new
      CalibrationSession.where(id: original_calibration_session_ids).each do |session|
        if session.can_start_calibration?
          owner_calibrating_reminder.collect_need_sending_calibrating_remind(session)
          session.update(session_status: "calibrating")
        else
          session.update(session_status: "waiting_manager_score")
        end
      end
      owner_calibrating_reminder.send_calibrating_remind_messages

      CalibrationSession.where(id: new_calibration_session_ids).each do |session|
        if session.can_start_calibration?
          session.update(session_status: "calibrating")
        else
          session.update(session_status: "waiting_manager_score")
        end
      end
    end

    protected

    def set_page_layout_data
      super
      @_container_class = nil
    end

    private

    def prepare_table_headers_of_performance(job_role_evaluation_performances)
      job_role_evaluation_performances.collect do |jrep|
        {
          Header: jrep.obj_name,
          accessor: jrep.en_name
        }
      end.uniq
    end

    def save_params
      params.permit(:id, :format, :group_level, :confirm,
        mark_score: [:id_user, *Capability.performance_column_names, :id_cet, :id_euc,
          *Capability.management_column_names, *Capability.profession_column_names,
          *JobRoleEvaluationPerformance.en_column_names,
          :manager_overall_output, :manager_overall_improvement, :manager_overall_plan],
        company_evaluation_ids: [])
    end

    def table_headers(current_open_evaluations, group_level)
      need_review_evaluations = current_open_evaluations.where(company_evaluation_template: {group_level: group_level})
      job_role_evaluation_performances = JobRoleEvaluationPerformance.need_review_job_role_evaluation_performance(need_review_evaluations)
      table_headers_of_performance = job_role_evaluation_performances.collect do |jrep|
        {
          Header: jrep.obj_name,
          accessor: jrep.en_name
        }
      end.uniq
      need_capabilities, job_role_ids = table_need_capabilities(need_review_evaluations)
      table_headers_of_capability = need_capabilities.collect do |cap|
        header = {
          Header: cap.name,
          accessor: cap.en_name # accessor is the "key" in the react table data
        }
        evaluation_role_ids = JobRole.where(id: job_role_ids).collect(&:evaluation_role_id).uniq
        if cap.evaluation_role_capabilities.where(evaluation_role_id: evaluation_role_ids).where(erc_description: nil).exists?
          header[:description] = cap.description
        end
        header
      end
      table_headers_of_capability(table_headers_of_capability, table_headers_of_performance)
    end

    def table_need_capabilities(evaluation_user_capabilities)
      job_role_ids = evaluation_user_capabilities.collect(&:job_role_id).uniq
      evaluation_role_ids = JobRole.where(id: job_role_ids).collect(&:evaluation_role_id).uniq
      capability_ids = EvaluationRoleCapability.where(evaluation_role_id: evaluation_role_ids).collect(&:capability_id).uniq
      [Capability.where(id: capability_ids).order(:category_name), job_role_ids]
    end

    def table_headers_of_capability(headers_of_capability, headers_of_performance)
      headers_of_performance
        .concat(headers_of_capability).append({
          Header: I18n.t("evaluation.total_evaluation_score"),
          accessor: "pre_total_evaluation_score",
          description: I18n.t("evaluation.total_evaluation_score_description")
        })
    end

    def check_mark_score_completion(need_review_evaluations, job_role_evaluation_performances)
      all_overall_not_valid_eucs = need_review_evaluations.find_all do |euc|
        euc.manager_overall_improvement&.length.to_i < 20 \
        || euc.manager_overall_plan&.length.to_i < 20
      end
      Rails.logger.debug "all_overall_not_valid_eucs: #{all_overall_not_valid_eucs}"

      any_attributes_zero_eucs = need_review_evaluations.find_all do |euc|
        euc.attributes.any? do |key, value|
          if %w[id company_evaluation_template_id user_id job_role_id
            calibration_management_profession_score calibration_performance_score calibration_work_load
            calibration_work_attitude calibration_work_quality].include?(key)
            false
          elsif value.nil? || !value.is_a?(BigDecimal)
            false
          else
            value.zero?
          end
        end
      end

      Rails.logger.debug "any_attributes_zero_eucs: #{any_attributes_zero_eucs}"

      any_obj_result_zero_jreps = job_role_evaluation_performances.find_all do |jrep|
        jrep.obj_result_fixed == false && jrep.obj_result.zero?
      end

      Rails.logger.debug "any_obj_result_zero_jreps: #{any_obj_result_zero_jreps}"

      all_on_self_assessment_done = need_review_evaluations.all? do |euc|
        euc.form_status == "self_assessment_done"
      end

      reject_message = []
      if all_overall_not_valid_eucs.length > 0
        user_chinese_name = all_overall_not_valid_eucs.collect { |euc| euc.user.chinese_name }
        reject_message << I18n.t("evaluation.any_manager_overall_not_valid_reject_message", user_names: user_chinese_name.to_sentence(words_connector: "、", last_word_connector: "和", two_words_connector: "、"))
      end
      if any_attributes_zero_eucs.length > 0
        user_chinese_name = any_attributes_zero_eucs.collect { |euc| euc.user.chinese_name }
        reject_message << I18n.t("evaluation.any_attitude_zero_reject_message", user_names: user_chinese_name.to_sentence(words_connector: "、", last_word_connector: "和", two_words_connector: "、"))
      end
      if any_obj_result_zero_jreps.length > 0
        user_chinese_name = any_obj_result_zero_jreps.collect { |jrep| jrep.user.chinese_name }
        reject_message << I18n.t("evaluation.any_obj_result_zero_reject_message", user_names: user_chinese_name.to_sentence(words_connector: "、", last_word_connector: "和", two_words_connector: "、"))
      end
      if !all_on_self_assessment_done
        reject_message << I18n.t("evaluation.not_all_on_self_assessment_done_reject_message")
      end
      reject_message.join("")
    end
  end
end
