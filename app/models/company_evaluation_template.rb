class CompanyEvaluationTemplate < ApplicationRecord
  GROUP_LEVELS = %w[staff manager_a manager_b auxiliary].freeze
  STAFF_DISTRIBUTION_GROUP_LEVELS = %w[staff auxiliary manager_b].freeze
  MANAGER_DISTRIBUTION_GROUP_LEVELS = %w[manager_a].freeze
  CALIBRATION_VERTICAL_SCORES = {"1" => 5, "2" => 3, "3" => 1}.freeze
  CALIBRATION_HORIZONTAL_SCORES = {"1" => 1, "2" => 3, "3" => 5}.freeze

  belongs_to :company_evaluation
  has_many :calibration_templates
  has_many :evaluation_user_capabilities
  validates :title, :group_level, presence: true

  def self.group_level_options
    {
      I18n.t("evaluation.staff_level") => "staff",
      I18n.t("evaluation.manager_level_a") => "manager_a",
      I18n.t("evaluation.manager_level_b") => "manager_b",
      I18n.t("evaluation.auxiliary_level") => "auxiliary"
    }
  end

  def self.staff_distribution_group_level?(group_level)
    STAFF_DISTRIBUTION_GROUP_LEVELS.include?(group_level)
  end

  def self.manager_distribution_group_level?(group_level)
    MANAGER_DISTRIBUTION_GROUP_LEVELS.include?(group_level)
  end

  def self.manager_b_group_level?(group_level)
    group_level == "manager_b"
  end

  def self.group_evaluation_user_capabilities(group_level, evaluation_user_capabilities)
    new(group_level: group_level).group_evaluation_user_capabilities(evaluation_user_capabilities)
  end

  def staff?
    group_level == "staff"
  end

  def manager_a?
    group_level == "manager_a"
  end

  def manager_b?
    self.class.manager_b_group_level?(group_level)
  end

  def auxiliary?
    group_level == "auxiliary"
  end

  def staff_distribution?
    self.class.staff_distribution_group_level?(group_level)
  end

  def manager_distribution?
    self.class.manager_distribution_group_level?(group_level)
  end

  def includes_performance_columns?
    !manager_b?
  end

  def calibration_table_partial
    staff? ? "ui/calibration_sessions/staff_table" : "ui/calibration_sessions/manager_table"
  end

  def square_template
    "#{group_level}_square"
  end

  def group_evaluation_user_capabilities(evaluation_user_capabilities)
    evaluation_user_capabilities.group_by do |euc|
      "#{vertical_position_for(euc)}#{horizontal_position_for(euc)}"
    end
  end

  def horizontal_position_for(evaluation_user_capability)
    if staff?
      evaluation_user_capability.group_of_staff_work_quality_and_work_attitude
    elsif manager_b?
      evaluation_user_capability.group_of_manager_only_management
    else
      evaluation_user_capability.group_of_manager_management_profession
    end
  end

  def vertical_position_for(evaluation_user_capability)
    if staff?
      evaluation_user_capability.group_of_staff_work_load
    elsif manager_b?
      evaluation_user_capability.group_of_manager_only_profession
    else
      evaluation_user_capability.group_of_manager_performance
    end
  end

  def calibration_attributes_for_square(square_key, evaluation_user_capability)
    row, column = square_key.to_s.chars
    vertical_score = CALIBRATION_VERTICAL_SCORES.fetch(row)
    horizontal_score = CALIBRATION_HORIZONTAL_SCORES.fetch(column)

    if staff?
      {
        calibration_work_quality: horizontal_score,
        calibration_work_load: vertical_score,
        calibration_work_attitude: evaluation_user_capability.work_attitude
      }
    elsif manager_b?
      {
        calibration_management_score: horizontal_score,
        calibration_profession_score: vertical_score
      }
    else
      {
        calibration_management_profession_score: horizontal_score,
        calibration_performance_score: vertical_score
      }
    end
  end
end
