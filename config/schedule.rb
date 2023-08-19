# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

every :day, at: "08:12am", roles: [:db] do
  rake "import:all"
end

every :day, at: "1:30am", roles: [:db] do
  rake "maintain:reconcile_session_status"
end

every "0 11 * * 1,3,5", roles: [:db] do
  rake "maintain:sent_pending_confirm_reminder_via_wechat"
end

# Learn more: http://github.com/javan/whenever
