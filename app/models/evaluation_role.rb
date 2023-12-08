class EvaluationRole < ApplicationRecord
  has_many :job_roles
  has_many :evaluation_role_capabilities, dependent: :destroy
  has_many :capabilities, through: :evaluation_role_capabilities
  has_many :ended_company_evaluation_role_capabilities

  def capability_ids
    @_capability_ids ||= evaluation_role_capabilities.collect(&:capability_id)
  end

  def capability_ids=(values)
    select_values = Array(values).reject(&:blank?).map(&:to_i)
    if new_record?
      (select_values - capability_ids).each do |to_new_id|
        evaluation_role_capabilities.build(capability_id: to_new_id)
      end
    else
      (capability_ids - select_values).each do |to_destroy_id|
        evaluation_role_capabilities.find_by(capability_id: to_destroy_id).destroy
      end
      (select_values - capability_ids).each do |to_add_id|
        evaluation_role_capabilities.create(capability_id: to_add_id)
      end
    end
  end
end
