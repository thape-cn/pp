class InitiationNewPerformance
  def self.do_import(company_evaluation, excel_file)
    xlsx = Roo::Excelx.new(StringIO.new(excel_file.download))

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
      next if h[:action] == "操作" || h[:import_guid] == "指标ID"
      if user.blank?
        puts "User not found by clerk_code: #{h[:user_clerk_code]}"
        next
      end

      jrep = JobRoleEvaluationPerformance.find_or_initialize_by(import_guid: h[:import_guid])
      jrep.user_id = user.id
      jrep.company_evaluation_id = company_evaluation.id
      jrep.dept_code = h[:dept_code]
      jrep.en_name = h[:p_tablename]
      jrep.st_code = h[:st_code]
      jrep.obj_name = h[:obj_name]
      jrep.obj_metric = h[:obj_metric]
      jrep.obj_weight_pct = h[:obj_weight_pct]
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
  end
end
