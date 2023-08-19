Sidekiq.configure_server do |config|
  config.average_scheduled_poll_interval = 2
  if Rails.application.credentials[Rails.env.to_sym].present?
    config.redis = {url: "redis://#{Rails.application.credentials.redis_server!}:#{Rails.application.credentials.redis_port!}/#{Rails.application.credentials[Rails.env.to_sym][:redis_db_num]}"}
  end
end

Sidekiq.configure_client do |config|
  if Rails.application.credentials[Rails.env.to_sym].present?
    config.redis = {url: "redis://#{Rails.application.credentials.redis_server!}:#{Rails.application.credentials.redis_port!}/#{Rails.application.credentials[Rails.env.to_sym][:redis_db_num]}"}
  end
end
