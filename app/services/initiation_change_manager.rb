class InitiationChangeManager
  def self.do_change(csv_file_path)
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
end
