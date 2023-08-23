namespace :activate do
  desc "Change manager in case NC not right and need manually fix."
  task :change_manager, [:csv_file] => [:environment] do |task, args|
    csv_file_path = args[:csv_file]
    return unless csv_file_path.present?

    Initiation.change_manager(csv_file_path)
  end

  desc "Create the CalibrationSession"
  task :calibration_user, [:company_evaluation_id, :excel_file] => [:environment] do |task, args|
    company_evaluation_id = args[:company_evaluation_id]
    excel_file_path = args[:excel_file]
    return unless excel_file_path.present?

    company_evaluation = CompanyEvaluation.find(company_evaluation_id)

    Initiation.new_calibration(company_evaluation, excel_file_path)
  end
end
