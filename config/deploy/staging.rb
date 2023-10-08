set :application, "rails_starter"
set :repo_url, "https://github.com/thape-cn/pp.git"
set :nginx_use_ssl, true
set :branch, :main
set :rails_env, "production"
set :puma_service_unit_name, :puma_rails_starter
set :puma_systemctl_user, :system
set :sidekiq_service_unit_name, "sidekiq_pp_vendor"
set :sidekiq_service_unit_user, :system

server "bandwagon", user: "starter", roles: %w[app db web]
