class Initiation
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
