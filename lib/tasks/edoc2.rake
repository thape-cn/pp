namespace :edoc2 do
  desc "Add calibration judge in batch"
  task :generate_pdf_files, [:company_evaluation_id, :user_id] => [:environment] do |task, args|
    company_evaluation_id = args[:company_evaluation_id]
    user_id = args[:user_id]

    company_evaluation_template_ids = CompanyEvaluation.find(company_evaluation_id).company_evaluation_templates.pluck(:id)
    eucs = EvaluationUserCapability
      .where(form_status: %w[hr_review_completed data_locked], company_evaluation_template_id: company_evaluation_template_ids)
      .where.not(company: "测试公司")
      .where.not(id: 833)
    eucs = eucs.where(user_id: user_id) if user_id.present?
    eucs.each do |euc|
      puts "Upload euc id: #{euc.id}"
      euc.generate_pdf_file
      euc.upload_pdf_to_edoc
      euc.upload_meta_arch
    end
  end
end
