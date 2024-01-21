set :application, "pp_staging"
set :repo_url, "https://github.com/thape-cn/pp.git"
set :nginx_use_ssl, true
set :branch, :main
set :rails_env, "production"
set :puma_service_unit_name, :puma_pp_staging
set :puma_systemctl_user, :system
set :sidekiq_service_unit_name, "sidekiq_pp_staging"
set :sidekiq_service_unit_user, :system

server "bandwagon", user: "pgac", roles: %w[app db web]
