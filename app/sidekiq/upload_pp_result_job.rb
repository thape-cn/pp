class UploadPpResultJob
  include MetricHelper
  include Sidekiq::Job

  def perform(evaluation_user_capability_id)
    euc = EvaluationUserCapability.find_by(id: evaluation_user_capability_id)
    return unless euc.present?
    clerk_code = euc.user&.clerk_code
    return unless clerk_code.present?

    performance_rating = euc.total_score_in_metric

    response = HTTPX.post(Rails.application.credentials.pm_upload_service_url!,
      json: {
        secret: Rails.application.credentials.pm_upload_secret_key!,
        evaluation_user_capability_id: evaluation_user_capability_id,
        clerk_code: clerk_code,
        bonus_period: euc.company_evaluation_template.company_evaluation.bonus_period,
        performance_rating: performance_rating
      })

    unless response.status == 200
      Rails.logger.error "UploadPpResultJob failed #{evaluation_user_capability_id} with status #{response.status} clerk_code: #{clerk_code}: #{response.body}"
    end
  end
end
