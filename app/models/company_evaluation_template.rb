class CompanyEvaluationTemplate < ApplicationRecord
  include CompanyEvaluationTemplateGroupLevels

  GROUP_LEVELS = %w[staff manager_a manager_b auxiliary supervisor].freeze
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
      I18n.t("evaluation.auxiliary_level") => "auxiliary",
      I18n.t("evaluation.supervisor_level") => "supervisor"
    }
  end

  def self.mark_score_group_options
    {
      "主管及以上" => 4,
      "准主管" => 3,
      "一级 / A级以下" => 2,
      "三级 / C级及以下" => 1
    }
  end

  def self.group_evaluation_user_capabilities(group_level, evaluation_user_capabilities)
    new(group_level: group_level).group_evaluation_user_capabilities(evaluation_user_capabilities)
  end

  def job_role_performance_metric(job_role_evaluation_performance)
    public_send(job_role_performance_metric_key(job_role_evaluation_performance))
  end

  def job_role_performance_metric_key(job_role_evaluation_performance)
    JobRoleEvaluationPerformance.hidden_rank_en_name?(job_role_evaluation_performance.en_name) ?
      "rank_performance_metric" :
      "performance_metric"
  end

  def calibration_table_partial
    (staff? || supervisor?) ? "ui/calibration_sessions/staff_table" : "ui/calibration_sessions/manager_table"
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
    if staff? || supervisor?
      evaluation_user_capability.group_of_staff_work_quality_and_work_attitude
    elsif manager_b?
      evaluation_user_capability.group_of_manager_only_management
    else
      evaluation_user_capability.group_of_manager_management_profession
    end
  end

  def vertical_position_for(evaluation_user_capability)
    if staff? || supervisor?
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

    if staff? || supervisor?
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
