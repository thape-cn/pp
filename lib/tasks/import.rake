namespace :import do
  desc "Daily import employee info from SSO"
  task all: %i[user job_role link_user_job_role link_hrbp_user_managed_departments]

  desc "Import users"
  task :user, [:csv_file] => [:environment] do |task, args|
    csv_file_path = args[:csv_file] || "/home/pp_vendor/EmployeeData/thapeemployee_#{Date.today.strftime("%m%d%Y")}.csv"

    User.all.update_all(is_active: false)
    CSV.foreach(csv_file_path, headers: true) do |row|
      email = correct_email(row["EMAIL"])
      chinese_name = row["LASTNAME"].split("_").first
      hire_date = Date.strptime(row["HIREDATE"], "%Y 年 %m 月 %d 日")
      sf_user_name = row["USERNAME"]

      user = User.find_or_initialize_by(email: email)
      user.chinese_name = chinese_name
      user.hire_date = hire_date
      user.clerk_code = sf_user_name.split("_").first
      user.is_active = true
      success = user.save(validate: false)
      puts "email: #{email} failed #{user.errors.full_messages.to_sentence}" unless success
    end
  end

  desc "Import job role"
  task :job_role, [:csv_file] => [:environment] do |task, args|
    csv_file_path = args[:csv_file] || "/home/pp_vendor/EmployeeData/thapeemployee_#{Date.today.strftime("%m%d%Y")}.csv"

    CSV.foreach(csv_file_path, headers: true) do |row|
      st_code = row["STCODE"]
      job_level = row["JOBLEVEL"]
      job_code = row["JOBCODE"]
      job_family = row["JOBFAMILY"]

      job_role = JobRole.find_or_initialize_by(st_code: st_code)
      job_role.job_level = job_level
      job_role.job_code = job_code
      job_role.job_family = job_family
      success = job_role.save
      puts "job_role: #{st_code} failed #{job_role.errors.full_messages.to_sentence}" unless success
    end
  end

  desc "Link User and JobRole"
  task :link_user_job_role, [:csv_file] => [:environment] do |task, args|
    csv_file_path = args[:csv_file] || "/home/pp_vendor/EmployeeData/thapeemployee_#{Date.today.strftime("%m%d%Y")}.csv"

    UserJobRole.all.update_all(is_active: false)
    CSV.foreach(csv_file_path, headers: true) do |row|
      email = correct_email(row["EMAIL"])
      st_code = row["STCODE"]
      job_user_id = row["USERID"]
      manager_user_id = row["MANAGER"]

      company = row["CUSTOM06"]
      department = row["DEPARTMENT"]
      dept_code = row["CUSTOM01"]
      title = row["TITLE"]

      user = User.find_by email: email
      puts "user email not found: #{email}" unless user.present?
      job_role = JobRole.find_by st_code: st_code
      puts "job_role st_code not found: #{st_code}" unless job_role.present?
      manager_job_role = UserJobRole.find_by job_user_id: manager_user_id
      manager_user = manager_job_role&.user

      user_job_role = UserJobRole.find_or_initialize_by(user_id: user.id, job_role_id: job_role.id, dept_code: dept_code)
      user_job_role.job_user_id = job_user_id
      if manager_user.present? && manager_user.id != user_job_role.manager_user_id
        EvaluationUserCapability.where(form_status: %w[initial self_assessment_done])
          .where(user_id: user.id, job_role_id: job_role.id, dept_code: dept_code)
          .update_all(manager_user_id: manager_user.id)
      end
      user_job_role.manager_user_id = manager_user&.id
      user_job_role.company = company
      user_job_role.department = department
      user_job_role.title = title
      user_job_role.is_active = true
      success = user_job_role.save

      puts "user_job_role: #{email} #{st_code} failed #{user_job_role.errors.full_messages.to_sentence}" unless success
    end
  end

  desc "Link user and HRBP user managed departments"
  task :link_hrbp_user_managed_departments, [:csv_file] => [:environment] do |task, args|
    csv_file_path = args[:csv_file] || "/home/pp_vendor/EmployeeData/thapeemployee_#{Date.today.strftime("%m%d%Y")}.csv"

    HrbpUserManagedDepartment.where(auto_generated: true).delete_all

    CSV.foreach(csv_file_path, headers: true) do |row|
      hr_job_user_id = row["HR"]
      next if hr_job_user_id == "NO_HR"
      dept_code = row["CUSTOM01"]

      first_part_of_user_id = hr_job_user_id.split("_")[0]
      hrbp_job_role = UserJobRole.find_by(job_user_id: hr_job_user_id)
      if hrbp_job_role.blank?
        hrbp_job_role = UserJobRole.find_by(job_user_id: "#{first_part_of_user_id}_Group")
      end
      if hrbp_job_role.blank?
        hrbp_job_role = UserJobRole.find_by(job_user_id: first_part_of_user_id)
      end
      if hrbp_job_role.present?
        hrbp = hrbp_job_role.user
        hrbp.hrbp_user_managed_departments.find_or_create_by(managed_dept_code: dept_code)
      else
        puts "hrbp_user_id: #{hr_job_user_id}/#{first_part_of_user_id}_Group/#{first_part_of_user_id} not found."
      end
    end
  end

  desc "Import Evaluation Role"
  task :evaluation_role, [:excel_file] => [:environment] do |task, args|
    excel_file_path = args[:excel_file]
    return unless excel_file_path.present?

    xlsx = Roo::Excelx.new(excel_file_path)
    xlsx.each(
      role_name: "考评角色"
    ) do |h|
      role_name = h[:role_name].to_s
      next if role_name.start_with?("1") || role_name == "考评角色"
      next if role_name.blank?

      er = EvaluationRole.find_or_initialize_by(role_name: role_name)
      success = er.save
      puts "evaluation_role: #{role_name} failed #{er.errors.full_messages.to_sentence}" unless success
    end
  end

  desc "Link JobRole and EvaluationRole"
  task :link_job_role_evaluation_role, [:excel_file] => [:environment] do |task, args|
    excel_file_path = args[:excel_file]
    return unless excel_file_path.present?

    xlsx = Roo::Excelx.new(excel_file_path)
    xlsx.each(
      st_code: "st_code",
      role_name: "考评角色"
    ) do |h|
      role_name = h[:role_name].to_s
      st_code = h[:st_code].to_s
      next if role_name.start_with?("1") || role_name == "考评角色"
      next if role_name.blank?

      er = EvaluationRole.find_by!(role_name: role_name)
      job_role = JobRole.find_by(st_code: st_code)
      if job_role.present?
        job_role.update(evaluation_role_id: er.id)
      else
        puts "job_role st_code: #{st_code} not found"
      end
    end
  end

  desc "Import Capability"
  task :capability, [:excel_file] => [:environment] do |task, args|
    excel_file_path = args[:excel_file]
    return unless excel_file_path.present?

    xlsx = Roo::Excelx.new(excel_file_path)
    xlsx.each(
      en_name: "name.en_US",
      name: "name.zh_CN",
      description: "description.zh_CN",
      category_name: "category_name"
    ) do |h|
      en_name = h[:en_name].to_s
      next if en_name == "英语标识" || en_name == "name.en_US"
      next if en_name.blank?

      capability = Capability.find_or_initialize_by(en_name: en_name)
      capability.name = h[:name]
      capability.description = h[:description]
      capability.category_name = h[:category_name]
      success = capability.save

      puts "capability: #{en_name} failed #{capability.errors.full_messages.to_sentence}" unless success
    end
  end

  def correct_email(email)
    first_email_part = email.split("@")[0]
    "#{first_email_part}@thape.com.cn"
  end
end
