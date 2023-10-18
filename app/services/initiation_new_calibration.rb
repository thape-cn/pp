class InitiationNewCalibration
  def self.do_validate_calibration_session(import_excel_file)
    xlsx = Roo::Excelx.new(StringIO.new(import_excel_file.excel_file.download))
    xlsx.default_sheet = "校准"

    import_excel_file.import_excel_file_messages.delete_all

    row_number = 1 # header having 1 row

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
      row_number += 1

      st_code = h[:st_code].to_s
      template_title = h[:template_title].to_s

      user = User.find_by(clerk_code: clerk_code)
      if user.blank?
        import_excel_file.import_excel_file_messages.create(row_number: row_number, message: I18n.t("errors.user_not_found", clerk_code: clerk_code))
      end

      job_role = JobRole.find_by(st_code: st_code)
      if job_role.blank?
        import_excel_file.import_excel_file_messages.create(row_number: row_number, message: I18n.t("errors.job_role_not_found", st_code: st_code))
      end

      company_evaluation_template = import_excel_file.company_evaluation.company_evaluation_templates.find_by(title: template_title)
      if company_evaluation_template.blank?
        import_excel_file.import_excel_file_messages.create(row_number: row_number, message: I18n.t("errors.company_evaluation_template_not_found", template_title: template_title))
      end

      evaluation_user_capability = EvaluationUserCapability.find_by(user_id: user.id, job_role_id: job_role.id, company_evaluation_template_id: company_evaluation_template.id)
      if evaluation_user_capability.blank?
        import_excel_file.import_excel_file_messages.create(row_number: row_number, message: "EvaluationUserCapability not found: #{template_title}, JobRole: #{st_code}")
      end

      calibration_owner = User.find_by(clerk_code: h[:calibration_owner].to_s)
      if calibration_owner.blank?
        import_excel_file.import_excel_file_messages.create(row_number: row_number, message: "Calibration owner not found by clerk_code: #{h[:calibration_owner]}")
      end

      h[:calibration_participants].to_s.split(";").each do |participant|
        judge = User.find_by(clerk_code: participant)
        if judge.blank?
          import_excel_file.import_excel_file_messages.create(row_number: row_number, message: "Calibration participants not found by clerk_code: #{participant}")
        end
      end
    end

    if import_excel_file.import_excel_file_messages.present?
      import_excel_file.update(file_status: "validate_failed")
    else
      import_excel_file.update(file_status: "validated")
    end
  end

  def self.do_import_calibration_session(import_excel_file)
    import_excel_file.update(file_status: "do_importing")
    xlsx = Roo::Excelx.new(StringIO.new(import_excel_file.excel_file.download))
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
      company_evaluation_template = import_excel_file.company_evaluation.company_evaluation_templates.find_by!(title: template_title)
      evaluation_user_capability = EvaluationUserCapability.find_by!(user_id: user.id, job_role_id: job_role.id, company_evaluation_template_id: company_evaluation_template.id)
      calibration_owner = User.find_by!(clerk_code: h[:calibration_owner].to_s)

      calibration_template = company_evaluation_template.calibration_templates.find_or_create_by(template_name: h[:calibration_template_name].to_s)

      calibration_session = calibration_template.calibration_sessions.find_or_create_by(session_name: h[:calibration_session_name].to_s, owner_id: calibration_owner.id)
      h[:calibration_participants].to_s.split(";").each do |participant|
        judge = User.find_by!(clerk_code: participant)
        calibration_session.calibration_session_judges.find_or_create_by(judge_id: judge.id)
      end
      calibration_session.calibration_session_users.find_or_create_by(user_id: user.id, evaluation_user_capability_id: evaluation_user_capability.id)
    end
    import_excel_file.update(file_status: "imported")
  end
end
