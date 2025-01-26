if Rails.env.production?
  RorVsWild.start(
    api_key: Rails.application.credentials.rorvswild_api_key,
    ignore_requests: %w[
      Gitlab::RequestForgeryProtection::Controller#index
    ],
    ignore_jobs: [],
    ignore_exceptions: [],
    ignore_plugins: %w[
      Elasticsearch
      Mongo
      Resque
      DelayedJob
    ]
  )
end
