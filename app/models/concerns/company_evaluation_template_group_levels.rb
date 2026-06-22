module CompanyEvaluationTemplateGroupLevels
  extend ActiveSupport::Concern

  STAFF_DISTRIBUTION_GROUP_LEVELS = %w[staff auxiliary manager_b].freeze
  MANAGER_DISTRIBUTION_GROUP_LEVELS = %w[manager_a].freeze

  class_methods do
    def staff_distribution_group_level?(group_level)
      STAFF_DISTRIBUTION_GROUP_LEVELS.include?(group_level)
    end

    def manager_distribution_group_level?(group_level)
      MANAGER_DISTRIBUTION_GROUP_LEVELS.include?(group_level)
    end

    def manager_b_group_level?(group_level)
      group_level == "manager_b"
    end
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
end
