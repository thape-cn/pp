namespace :maintain do
  desc "Check if All current capability en_name having column in evaluation_user_capabilities"
  task evaluation_user_capabilities_intact: :environment do
    puts "No evaluation_user_capabilities capability columns(should be blank): ", Capability.no_evaluation_user_capabilities_column_names
  end

  desc "Reconcile session status"
  task reconcile_session_status: :environment do
    open_company_evaluation_ids = CompanyEvaluation.open_for_user.collect(&:id)
    CalibrationSession.reconcile_session_status(open_company_evaluation_ids)
  end

  desc "Remove leaving employee current open evaluation user capability"
  task remove_leaving_employee_eucs: :environment do
    CompanyEvaluation.open_for_user.each do |company_evaluation|
      company_evaluation.remove_leaving_employee_eucs
    end
  end

  desc "Clean PP test company evaluation data"
  task :clean_pp_test_company_evaluation_data, [:company_evaluation_id] => [:environment] do |task, args|
    company_evaluation_id = args[:company_evaluation_id]

    company_evaluation = CompanyEvaluation.find(company_evaluation_id)
    Initiation.clean_pp_test_company_evaluation_data(company_evaluation)
  end

  desc "Add calibration judge in batch"
  task :add_calibration_judge_in_batch, [:company_evaluation_id, :company, :user_id] => [:environment] do |task, args|
    company_evaluation_id = args[:company_evaluation_id]
    company = args[:company]
    user_id = args[:user_id]

    company_evaluation_template_ids = CompanyEvaluation.find(company_evaluation_id).company_evaluation_templates.pluck(:id)
    evaluation_user_capability_ids = EvaluationUserCapability.where(company_evaluation_template_id: company_evaluation_template_ids, company: company).pluck(:id)
    CalibrationSessionUser.where(evaluation_user_capability_id: evaluation_user_capability_ids).each do |csu|
      calibration_session = csu.calibration_session
      next if calibration_session.owner_id == user_id

      calibration_session.calibration_session_judges.find_or_create_by!(judge_id: user_id)
    end
  end

  desc "Sent pending confirm reminder via wechat"
  task sent_pending_confirm_reminder_via_wechat: :environment do
    open_company_evaluation_ids = CompanyEvaluation.open_for_user.collect(&:id)
    PendingStaffConfirmReminder.sent_wechat_message(open_company_evaluation_ids)
  end

  desc "Remove imported calibration session"
  task :remove_imported_calibration_session, [:company_evaluation_id, :excel_file] => [:environment] do |task, args|
    company_evaluation_id = args[:company_evaluation_id]
    company_evaluation = CompanyEvaluation.find(company_evaluation_id.to_i)
    excel_file_path = args[:excel_file]

    return unless excel_file_path.present?

    xlsx = Roo::Excelx.new(excel_file_path)
    xlsx.default_sheet = "校准"
    xlsx.each(
      clerk_code: "USERNAME",
      dept_code: "CUSTOM01",
      st_code: "STCODE",
      template_title: "Template",
      calibration_template_name: "Calibration Template",
      calibration_session_name: "Calibration Session",
      calibration_owner: "Calibration Owner",
      calibration_participants: "Calibration Participants"
    ) do |h|
      clerk_code = h[:clerk_code].to_s
      next if clerk_code == "USERNAME"
      next if clerk_code.blank?

      st_code = h[:st_code].to_s
      template_title = h[:template_title].to_s

      user = User.find_by!(clerk_code: clerk_code)
      job_role = JobRole.find_by!(st_code: st_code)
      company_evaluation_template = company_evaluation.company_evaluation_templates.find_by!(title: template_title)
      evaluation_user_capability = EvaluationUserCapability.find_by!(user_id: user.id, job_role_id: job_role.id, company_evaluation_template_id: company_evaluation_template.id)
      CalibrationSessionUser.where(user_id: user.id, evaluation_user_capability_id: evaluation_user_capability.id).delete_all
    end
    missing_calibration_session_users = CalibrationSession.where.missing(:calibration_session_users)
    missing_calibration_session_users.update_all(session_status: "reconciliation_needed")
  end

  desc "Upload pp result in batch"
  task :upload_pp_result_in_batch, [:company_evaluation_id] => [:environment] do |task, args|
    company_evaluation_id = args[:company_evaluation_id]

    company_evaluation_template_ids = CompanyEvaluation.find(company_evaluation_id).company_evaluation_templates.pluck(:id)
    eucs = EvaluationUserCapability.order(:id)
      .where(form_status: %w[hr_review_completed data_locked], company_evaluation_template_id: company_evaluation_template_ids)
    eucs.each do |evaluation_user_capability|
      UploadPpResultJob.perform_inline(evaluation_user_capability.id)
    end
  end
end
