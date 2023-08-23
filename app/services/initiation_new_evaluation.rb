class InitiationNewEvaluation
  def self.do_import(company_evaluation, excel_file)
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
end
