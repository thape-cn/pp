#!/usr/bin/env puma

directory "/var/www/pp_staging/current"
rackup "/var/www/pp_staging/current/config.ru"
environment "production"

tag ""

pidfile "/var/www/pp_staging/shared/tmp/pids/puma.pid"
state_path "/var/www/pp_staging/shared/tmp/pids/puma.state"
stdout_redirect "/var/www/pp_staging/shared/log/puma_access.log", "/var/www/pp_staging/shared/log/puma_error.log", true

threads 0, 16

bind "unix:///var/www/pp_staging/shared/tmp/sockets/puma.sock"

workers 0

restart_command "bundle exec puma"

prune_bundler

on_restart do
  puts "Refreshing Gemfile"
  ENV["BUNDLE_GEMFILE"] = ""
end
