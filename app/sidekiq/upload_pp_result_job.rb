class UploadPpResultJob
  include Sidekiq::Job

  def perform(evaluation_user_capability_id)
    euc = EvaluationUserCapability.find_by(id: evaluation_user_capability_id)
    return unless euc.present?

    response = HTTP.post(Rails.application.credentials.pm_upload_service_url!,
      json: {
        secret: Rails.application.credentials.pm_upload_secret_key!,
        clerk_code: euc.user.clerk_code,
        bonus_period: euc.company_evaluation_template.company_evaluation.bonus_period,
        performance_rating: euc.total_evaluation_score
      })

    unless response.status == 200
      Rails.logger.error "UploadPpResultJob failed with status #{response.status} clerk_code: #{clerk_code}: #{response.body}"
    end
  end
end
