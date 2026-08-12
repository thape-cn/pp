class CalibrationTemplate < ApplicationRecord
  belongs_to :company_evaluation
  has_many :calibration_template_company_evaluation_templates, dependent: :destroy
  has_many :company_evaluation_templates, through: :calibration_template_company_evaluation_templates
  has_many :calibration_sessions
  validates :company_evaluation_templates, presence: true
  validate :company_evaluation_templates_belong_to_company_evaluation

  def self.hamilton_method(populations, seats)
    total_population = populations.values.inject(:+)
    divisor = total_population.to_f / seats
    quotas = populations.map { |state, population| [state, population / divisor] }.to_h
    lower_quotas = quotas.map { |state, quota| [state, quota.floor] }.to_h
    initial_seats = lower_quotas.values.inject(:+)
    remaining_seats = seats - initial_seats
    decimal_parts = quotas.map { |state, quota| [state, (quota - quota.floor).round(7)] }.to_h
    sorted_decimal_parts = decimal_parts.sort_by { |state, decimal| -decimal }
    remaining_states = sorted_decimal_parts.first(remaining_seats).map(&:first)
    remaining_states.each { |state| lower_quotas[state] += 1 }
    lower_quotas
  end

  def self.open_for_user_calibration_template_ids
    where(company_evaluation_id: CompanyEvaluation.open_for_user.select(:id)).pluck(:id)
  end

  private

  def company_evaluation_templates_belong_to_company_evaluation
    return if company_evaluation.blank?
    return if company_evaluation_templates.all? { |template| template.company_evaluation_id == company_evaluation_id }

    errors.add(:company_evaluation_templates, "must belong to the same company evaluation")
  end
end
