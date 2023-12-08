class ArchiveCompanyEvaluationRoleCapabilityJob
  include Sidekiq::Job

  def perform(company_evaluation_id)
    EvaluationRoleCapability.all.each do |erc|
      cerc_description = erc.erc_description.presence || erc.capability.description.presence || ""
      EndedCompanyEvaluationRoleCapability.create(company_evaluation_id: company_evaluation_id,
        evaluation_role_id: erc.evaluation_role_id,
        capability_id: erc.capability_id,
        cerc_description: cerc_description)
    end
  end
end
