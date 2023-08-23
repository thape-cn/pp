namespace :activate do
  desc "Change manager in case NC not right and need manually fix."
  task :change_manager, [:csv_file] => [:environment] do |task, args|
    csv_file_path = args[:csv_file]
    return unless csv_file_path.present?

    Initiation.change_manager(csv_file_path)
  end
end
