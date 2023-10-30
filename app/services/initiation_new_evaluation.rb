class InitiationNewEvaluation
  def self.do_validate_euc(import_excel_file)
    xlsx = Roo::Excelx.new(StringIO.new(import_excel_file.excel_file.download))
    xlsx.default_sheet = "启动表单"

    import_excel_file.import_excel_file_messages.delete_all

    row_number = 1 # header having 1 row

    seen_rows = {} # Hash to keep track of seen rows

    xlsx.each(
      clerk_code: "USERNAME",
      dept_code: "CUSTOM01",
      st_code: "STCODE",
      template_title: "Template"
    ) do |h|
      clerk_code = h[:clerk_code].to_s
      next if clerk_code == "USERNAME"
      next if clerk_code.blank?
      row_number += 1

      dept_code = h[:dept_code].to_s
      st_code = h[:st_code].to_s
      template_title = h[:template_title].to_s

      # Check for duplicate row
      row_key = [clerk_code, dept_code, st_code].join("-")
      if seen_rows[row_key]
        import_excel_file.import_excel_file_messages.create(row_number: row_number, message: I18n.t("errors.duplicate_row", clerk_code: clerk_code, dept_code: dept_code, st_code: st_code))
        next
      else
        seen_rows[row_key] = true
      end

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

      ujr = UserJobRole.find_by(user_id: user.id, job_role_id: job_role.id, dept_code: dept_code)
      if ujr.blank?
        import_excel_file.import_excel_file_messages.create(row_number: row_number, message: I18n.t("errors.user_job_role_not_found", dept_code: dept_code))
      end

      existing_euc = EvaluationUserCapability.find_by(user_id: user.id, job_role_id: job_role.id, company_evaluation_template_id: company_evaluation_template.id)
      if existing_euc.present?
        import_excel_file.import_excel_file_messages.create(row_number: row_number, message: I18n.t("errors.evaluation_user_capability_exists", clerk_code: clerk_code, st_code: st_code, template_title: template_title))
      end
    end

    if import_excel_file.import_excel_file_messages.present?
      import_excel_file.update(file_status: "validate_failed")
    else
      import_excel_file.update(file_status: "validated")
    end
  end

  def self.do_import_euc(import_excel_file)
    import_excel_file.update(file_status: "do_importing")
    xlsx = Roo::Excelx.new(StringIO.new(import_excel_file.excel_file.download))
    xlsx.default_sheet = "启动表单"
    row_number = 1 # header having 1 row

    xlsx.each(
      clerk_code: "USERNAME",
      dept_code: "CUSTOM01",
      st_code: "STCODE",
      template_title: "Template"
    ) do |h|
      clerk_code = h[:clerk_code].to_s
      next if clerk_code == "USERNAME"
      next if clerk_code.blank?
      row_number += 1

      dept_code = h[:dept_code].to_s
      st_code = h[:st_code].to_s
      template_title = h[:template_title].to_s

      user = User.find_by!(clerk_code: clerk_code)
      job_role = JobRole.find_by!(st_code: st_code)
      company_evaluation_template = import_excel_file.company_evaluation.company_evaluation_templates.find_by!(title: template_title)
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
      unless success
        import_excel_file.import_excel_file_messages.create(row_number: row_number, message: I18n.t("errors.evaluation_user_capability_failed", dept_code: dept_code, clerk_code: clerk_code, template_title: template_title, error_messages: evaluation_user_capability.errors.full_messages.to_sentence))
      end
    end
    import_excel_file.update(file_status: "imported")
  end
end
