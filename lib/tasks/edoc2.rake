namespace :edoc2 do
  desc "Add calibration judge in batch"
  task :generate_pdf_files, [:company_evaluation_id, :written_date, :eucs_id] => [:environment] do |task, args|
    company_evaluation_id = args[:company_evaluation_id]
    written_date = args[:written_date]
    eucs_id = args[:eucs_id].to_i
    end_eucs_id = eucs_id + 100

    company_evaluation_template_ids = CompanyEvaluation.find(company_evaluation_id).company_evaluation_templates.pluck(:id)
    eucs = EvaluationUserCapability
      .where(form_status: %w[hr_review_completed data_locked], company_evaluation_template_id: company_evaluation_template_ids)
      .where.not(company: "测试公司")
      .where("id >= ? AND id < ?", eucs_id, end_eucs_id)
    eucs.each do |euc|
      puts "Upload euc id: #{euc.id}"
      euc.generate_pdf_file
      euc.upload_pdf_to_edoc
      euc.upload_meta_arch(written_date)
    end
  end
end
