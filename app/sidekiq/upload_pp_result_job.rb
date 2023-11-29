class UploadPpResultJob
  include Sidekiq::Job

  def perform(evaluation_user_capability_id)
    euc = EvaluationUserCapability.find_by(id: evaluation_user_capability_id)
    return unless euc.present?

    response = HTTP.post(Rails.application.credentials.pm_upload_service_url!,
      json: {
        secret: Rails.application.credentials.pm_upload_secret_key!,
        clerk_code: euc.user.clerk_code,
        bonus_period: "2023-06",
        performance_rating: euc.total_evaluation_score
      })

    unless response.status == 200
      Rails.logger.error "UploadPpResultJob failed with status #{response.status}: #{response.body}"
    end
  end
end
