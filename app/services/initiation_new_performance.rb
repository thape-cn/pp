class InitiationNewPerformance
  def self.do_import(company_evaluation, csv_file_path)
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
end
