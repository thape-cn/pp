class InitiationNewPerformance
  def self.do_validate_jrep(import_excel_file)
    xlsx = Roo::Excelx.new(StringIO.new(import_excel_file.excel_file.download))

    import_excel_file.import_excel_file_messages.delete_all

    row_number = 2 # header having 2 row
    xlsx.each(
      action: "ACTION",
      import_guid: "GUID",
      user_clerk_code: "USER",
      dept_code: "DEPTCODE",
      st_code: "st_code",
      p_tablename: "p_tablename",
      obj_name: "OBJECTIVE_name",
      obj_metric: "OBJECTIVE_metric",
      obj_weight_pct: "OBJECTIVE_weight",
      obj_result: "OBJECTIVE_result",
      obj_upload: "OBJECTIVE_upload"
    ) do |h|
      user = User.find_by(clerk_code: h[:user_clerk_code])
      next if h[:action] == "操作" && h[:import_guid] == "指标ID"
      next if h[:action] == "ACTION" && h[:import_guid] == "GUID"
      row_number += 1

      if user.blank?
        import_excel_file.import_excel_file_messages.create(row_number: row_number, message: "User not found by clerk_code: #{h[:user_clerk_code]}")
      end
    end

    if import_excel_file.import_excel_file_messages.present?
      import_excel_file.update(file_status: "validate_failed")
    else
      import_excel_file.update(file_status: "validated")
    end
  end

  def self.do_import_jrep(import_excel_file)
    import_excel_file.update(file_status: "do_importing")
    xlsx = Roo::Excelx.new(StringIO.new(import_excel_file.excel_file.download))

    import_excel_file.import_excel_file_messages.delete_all

    xlsx.each(
      action: "ACTION",
      import_guid: "GUID",
      user_clerk_code: "USER",
      dept_code: "DEPTCODE",
      st_code: "st_code",
      p_tablename: "p_tablename",
      obj_name: "OBJECTIVE_name",
      obj_metric: "OBJECTIVE_metric",
      obj_weight_pct: "OBJECTIVE_weight",
      obj_result: "OBJECTIVE_result",
      obj_upload: "OBJECTIVE_upload"
    ) do |h|
      user = User.find_by(clerk_code: h[:user_clerk_code])
      next if h[:action] == "操作" && h[:import_guid] == "指标ID"
      next if h[:action] == "ACTION" && h[:import_guid] == "GUID"

      jrep = JobRoleEvaluationPerformance.find_or_initialize_by(import_guid: h[:import_guid])
      jrep.user_id = user.id
      jrep.company_evaluation_id = import_excel_file.company_evaluation.id
      jrep.dept_code = h[:dept_code]
      jrep.en_name = h[:p_tablename]
      jrep.st_code = h[:st_code]
      jrep.obj_name = h[:obj_name]
      jrep.obj_metric = h[:obj_metric]
      jrep.obj_weight_pct = h[:obj_weight_pct] * 100
      if h[:obj_upload] == "N"
        jrep.obj_result = 0
        jrep.obj_result_fixed = false
      else
        jrep.obj_result = h[:obj_result]
        jrep.obj_result_fixed = true
      end
      success = jrep.save
      puts "job role evaluation performance: #{h[:import_guid]} failed #{jrep.errors.full_messages.to_sentence}" unless success
    end
    import_excel_file.update(file_status: "imported")
  end
end
