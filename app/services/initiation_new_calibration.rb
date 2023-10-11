class InitiationNewCalibration
  def self.do_import_calibration_session(import_excel_file)
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

      user = User.find_by(clerk_code: clerk_code)
      job_role = JobRole.find_by(st_code: st_code)
      company_evaluation_template = import_excel_file.company_evaluation.company_evaluation_templates.find_by(title: template_title)
      evaluation_user_capability = EvaluationUserCapability.find_by(user_id: user.id, job_role_id: job_role.id, company_evaluation_template_id: company_evaluation_template.id)
      calibration_owner = User.find_by(clerk_code: h[:calibration_owner].to_s)

      calibration_template = company_evaluation_template.calibration_templates.find_or_create_by(template_name: h[:calibration_template_name].to_s)

      if calibration_owner.present?
        calibration_session = calibration_template.calibration_sessions.find_or_create_by(session_name: h[:calibration_session_name].to_s, owner_id: calibration_owner.id)
        h[:calibration_participants].to_s.split(";").each do |participant|
          judge = User.find_by(clerk_code: participant)
          calibration_session.calibration_session_judges.find_or_create_by(judge_id: judge.id)
        end
        if evaluation_user_capability.present?
          calibration_session.calibration_session_users.find_or_create_by(user_id: user.id, evaluation_user_capability_id: evaluation_user_capability.id)
        else
          puts "evaluation_user_capability missing: user.id: #{user.id} job_role.id: #{job_role.id} company_evaluation_template.id: #{company_evaluation_template.id}"
        end
      else
        puts "calibration_owner missing: #{h[:calibration_owner]}"
      end
    end
  end
end
