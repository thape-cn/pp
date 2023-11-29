source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "~> 3.0"

gem "rails", "~> 7.1.1"

# `config/initializers/mail_starttls_patch.rb` has also been patched to
# fix STARTTLS handling until https://github.com/mikel/mail/pull/1536 is
# released.
gem "mail", "= 2.8.1"

gem "jbuilder"
gem "propshaft"

gem "sqlite3"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma"

gem "shakapacker"

# Use Redis adapter to run Action Cable in production
# gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

gem "devise"
gem "omniauth_openid_connect"
gem "devise-i18n"
gem "pundit"

gem "meta-tags"
gem "browser"

gem "config"

gem "ajax-datatables-rails"
gem "pagy"

gem "redcarpet"

gem "csv"
# To import the excel
gem "roo"
# To export excel using Axlsx::Package
gem "caxlsx"
# To save printed form as PDF.
gem "ferrum"

gem "local_time"

# bundle config local.wechat /Users/guochunzhong/git/oss/wechat/
gem "wechat", git: "https://github.com/Eric-Guo/wechat", branch: :main

# bundle config local.edoc2-api /Users/guochunzhong/git/sso/edoc2-api/
gem "edoc2-api", git: "https://git.thape.com.cn/rails/edoc2-api.git", branch: :main

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

gem "sidekiq"

gem "whenever", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", "~> 1.8.0", platforms: %i[mri mingw x64_mingw]

  gem "standard"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

  gem "capistrano"
  gem "capistrano-rails"
  gem "capistrano-yarn"
  gem "capistrano-rbenv"
  gem "capistrano3-puma", ">= 6.0.0.beta.1"
  gem "capistrano-sidekiq", "~> 2.3"

  gem "ed25519"
  gem "bcrypt_pbkdf"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver", ">= 4.11.0"
end
