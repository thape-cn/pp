class ReconcileSessionStatusJob
  include Sidekiq::Job

  def perform(company_evaluation_ids)
    CalibrationSession.reconcile_session_status(company_evaluation_ids)
  end
end
