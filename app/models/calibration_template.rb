class CalibrationTemplate < ApplicationRecord
  belongs_to :company_evaluation_template
  has_many :calibration_sessions

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
    open_company_evaluation_ids = CompanyEvaluation.open_for_user.pluck(:id)
    open_for_user_company_evaluation_template_ids = CompanyEvaluationTemplate.where(company_evaluation_id: open_company_evaluation_ids).pluck(:id)
    where(company_evaluation_template_id: open_for_user_company_evaluation_template_ids).pluck(:id)
  end
end
