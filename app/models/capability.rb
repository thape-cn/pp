class Capability < ApplicationRecord
  has_many :evaluation_role_capabilities, dependent: :destroy
  has_many :evaluation_roles, through: :evaluation_role_capabilities
  has_many :ended_company_evaluation_role_capabilities

  validates :category_name, presence: true
  validates :en_name, presence: true, uniqueness: true,
    format: {with: /\A[a-z_]+\z/, message: "only allows low case alphabet and '_'"}

  def display_name
    "#{name} - #{en_name}"
  end

  def job_role_description(job_role)
    evaluation_role_id = job_role.evaluation_role.id
    erc = evaluation_role_capabilities.find_by(evaluation_role_id: evaluation_role_id)
    erc&.erc_description.presence || description
  end

  def self.category_options
    @_category_options ||= select(:category_name)
      .distinct
      .pluck(:category_name)
  end

  def self.all_capability_column_names
    calibration_column_names + other_column_names + performance_column_names + management_column_names + profession_column_names
  end

  def self.calibration_column_names
    %w[calibration_management_profession_score
      calibration_performance_score
      calibration_work_load
      calibration_work_attitude
      calibration_work_quality]
  end

  def self.other_column_names
    @_other_column_names ||= where.not(category_name: %w[业绩产出（固定） 管理能力 专业能力]).pluck(:en_name)
  end

  # New 业绩产出（固定） is a new fixed_output, need add similar as work_attitude_pct in calibration_controller also.
  def self.performance_column_names
    @_performance_column_names ||= where(category_name: "业绩产出（固定）").pluck(:en_name)
  end

  def self.management_column_names
    @_management_column_names ||= where(category_name: "管理能力").pluck(:en_name)
  end

  def self.management_column_label_and_names
    @_management_column_label_and_names ||= where(category_name: "管理能力").pluck(:name, :en_name)
  end

  def self.profession_column_names
    @_profession_column_names ||= where(category_name: "专业能力").pluck(:en_name)
  end

  def self.profession_column_label_and_names
    @_profession_column_label_and_names ||= where(category_name: "专业能力").pluck(:name, :en_name)
  end

  def self.no_evaluation_user_capabilities_column_names
    all_capability_column_names - EvaluationUserCapability.column_names
  end
end
