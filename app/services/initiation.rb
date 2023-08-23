class Initiation
  def self.new_calibration(company_evaluation, excel_file)
    xlsx = Roo::Excelx.new(StringIO.new(excel_file.download))
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
      company_evaluation_template = company_evaluation.company_evaluation_templates.find_by(title: template_title)
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

  def self.change_manager(csv_file_path)
    CSV.foreach(csv_file_path, headers: true) do |row|
      dept_code = row["CUSTOM01"]
      st_code = row["STCODE"]
      clerk_code = row["USERNAME"]
      manager = row["MANAGER"]

      user = User.find_by(clerk_code: clerk_code)
      job_role = JobRole.find_by!(st_code: st_code)
      if user.blank?
        puts "User not found by clerk_code: #{clerk_code}"
        next
      end
      user_job_role = user.user_job_roles.find_by(dept_code: dept_code, job_role_id: job_role.id)
      if user_job_role.blank?
        puts "User job role not found by dept_code: #{dept_code} and job_role: #{job_role.id}"
        next
      end
      manager_job_role = UserJobRole.find_by job_user_id: manager
      manager_user = manager_job_role&.user

      if manager_user.blank?
        puts "Manager user not found by MANAGER: #{manager}"
        next
      end
      user_job_role.update(manager_user_id: manager_user.id)
    end
  end

  def self.new_evaluation(company_evaluation, excel_file)
    xlsx = Roo::Excelx.new(StringIO.new(excel_file.download))
    xlsx.default_sheet = "启动表单"

    xlsx.each(
      clerk_code: "USERNAME",
      dept_code: "CUSTOM01",
      st_code: "STCODE",
      template_title: "Template"
    ) do |h|
      clerk_code = h[:clerk_code].to_s
      next if clerk_code == "USERNAME"
      next if clerk_code.blank?

      dept_code = h[:dept_code].to_s
      st_code = h[:st_code].to_s
      template_title = h[:template_title].to_s

      user = User.find_by(clerk_code: clerk_code)
      if user.blank?
        puts "User not found by clerk_code: #{clerk_code}"
        next
      end
      job_role = JobRole.find_by(st_code: st_code)
      if job_role.blank?
        puts "Job_role not found by st_code: #{st_code}"
        next
      end
      company_evaluation_template = company_evaluation.company_evaluation_templates.find_by(title: template_title)
      if company_evaluation_template.blank?
        puts "Company evaluation template not found by title: #{template_title}"
        next
      end

      ujr = UserJobRole.find_by!(user_id: user.id, job_role_id: job_role.id, dept_code: dept_code)
      evaluation_user_capability = EvaluationUserCapability.new(user_id: user.id, job_role_id: job_role.id, company_evaluation_template_id: company_evaluation_template.id)
      evaluation_user_capability.manager_user_id = ujr.manager_user_id
      evaluation_user_capability.company = ujr.company
      evaluation_user_capability.department = ujr.department
      evaluation_user_capability.dept_code = ujr.dept_code
      evaluation_user_capability.title = ujr.title
      if (success = evaluation_user_capability.save)
        evaluation_user_capability.initial_capability_score_filling
      end
      puts "evaluation_user_capability: #{dept_code} #{clerk_code} #{template_title} failed #{evaluation_user_capability.errors.full_messages.to_sentence}" unless success
    end
  end

  def self.new_performance(company_evaluation, csv_file_path)
    CSV.foreach(csv_file_path, headers: true) do |row|
      action = row["ACTION"]
      import_guid = row["GUID"]
      user = User.find_by(clerk_code: row["USER"])
      dept_code = row["DEPTCODE"]
      p_tablename = row["p_tablename"]
      st_code = row["st_code"]
      obj_name = row["OBJECTIVE_name"]
      obj_metric = row["OBJECTIVE_metric"]
      obj_weight_pct = row["OBJECTIVE_weight"]
      obj_result = row["OBJECTIVE_result"]
      obj_upload = row["OBJECTIVE_upload"]

      next if action == "操作" || import_guid == "指标ID"
      if user.blank?
        puts "User not found by clerk_code: #{row["USER"]}"
        next
      end

      jrep = JobRoleEvaluationPerformance.find_or_initialize_by(import_guid: import_guid)
      jrep.user_id = user.id
      jrep.company_evaluation_id = company_evaluation.id
      jrep.dept_code = dept_code
      jrep.en_name = p_tablename
      jrep.st_code = st_code
      jrep.obj_name = obj_name
      jrep.obj_metric = obj_metric
      jrep.obj_weight_pct = obj_weight_pct
      if obj_upload == "N"
        jrep.obj_result = 0
        jrep.obj_result_fixed = false
      else
        jrep.obj_result = obj_result
        jrep.obj_result_fixed = true
      end
      success = jrep.save
      puts "job role evaluation performance: #{import_guid} failed #{jrep.errors.full_messages.to_sentence}" unless success
    end
  end

  def self.clean_pp_test_company_evaluation_data(company_evaluation)
    company_evaluation_template_ids = company_evaluation.company_evaluation_templates.pluck(:id)
    pp_test_user_ids = User.where('email LIKE "pptest%@thape.com.cn"').pluck(:id)
    EvaluationUserCapability.where(company_evaluation_template_id: company_evaluation_template_ids,
      user_id: pp_test_user_ids).each do |euc|
      euc.destroy
    end
    JobRoleEvaluationPerformance.where(company_evaluation_id: company_evaluation.id,
      user_id: pp_test_user_ids).each do |jrep|
      jrep.destroy
    end
    CalibrationSessionUser.where(user_id: pp_test_user_ids).each do |csu|
      next if csu.evaluation_user_capability.present?
      csu.destroy
    end
    calibration_template_ids = CalibrationTemplate.where(company_evaluation_template_id: company_evaluation_template_ids).pluck(:id)
    CalibrationSession.where(calibration_template_id: calibration_template_ids).each do |session|
      next if session.calibration_session_users.present?
      session.destroy
    end
  end
end
