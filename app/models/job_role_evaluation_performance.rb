class JobRoleEvaluationPerformance < ApplicationRecord
  HIDDEN_RANK_EN_NAMES = %w[
    p_managedproject_profit
    p_managedproject_output
    p_individual_output
    p_individual_hours
  ].freeze

  belongs_to :user
  belongs_to :company_evaluation
  belongs_to :evaluation_user_capability, optional: true

  scope :visible_in_staff_review, -> {
    where(en_name: nil).or(where.not(en_name: HIDDEN_RANK_EN_NAMES))
  }
  scope :managed_by, ->(manager_user_id) {
    where(<<~SQL.squish, manager_user_id)
      EXISTS (
        SELECT 1
        FROM evaluation_user_capabilities
        INNER JOIN company_evaluation_templates
          ON company_evaluation_templates.id = evaluation_user_capabilities.company_evaluation_template_id
        INNER JOIN job_roles
          ON job_roles.id = evaluation_user_capabilities.job_role_id
        WHERE evaluation_user_capabilities.user_id = job_role_evaluation_performances.user_id
          AND evaluation_user_capabilities.dept_code = job_role_evaluation_performances.dept_code
          AND job_roles.st_code = job_role_evaluation_performances.st_code
          AND company_evaluation_templates.company_evaluation_id = job_role_evaluation_performances.company_evaluation_id
          AND evaluation_user_capabilities.manager_user_id = ?
      )
    SQL
  }

  def self.visible_for_staff_review_by(evaluation_user_capability, user)
    performances = performance_from_evaluation_user_capability(evaluation_user_capability)
    return performances.visible_in_staff_review if evaluation_user_capability.user_id == user&.id

    performances
  end

  def self.hidden_rank_en_name?(en_name)
    HIDDEN_RANK_EN_NAMES.include?(en_name)
  end

  def hidden_in_staff_review_for?(user)
    user_id == user&.id && self.class.hidden_rank_en_name?(en_name)
  end

  def self.en_column_names
    @_en_column_names ||= pluck(:en_name)
  end

  def self.performance_from_evaluation_user_capability(evaluation_user_capability)
    all.where(user_id: evaluation_user_capability.user.id)
      .where(company_evaluation_id: evaluation_user_capability.company_evaluation_template.company_evaluation.id)
      .where(st_code: evaluation_user_capability.job_role.st_code)
      .where(dept_code: evaluation_user_capability.dept_code)
  end

  def self.need_review_job_role_evaluation_performance(need_review_evaluations)
    dept_codes = need_review_evaluations.collect(&:dept_code).uniq
    job_role_ids = need_review_evaluations.collect(&:job_role_id).uniq
    user_ids = need_review_evaluations.collect(&:user_id).uniq
    company_evaluation_template_ids = need_review_evaluations.collect(&:company_evaluation_template_id).uniq
    all.where(user_id: user_ids, dept_code: dept_codes)
      .where(st_code: JobRole.distinct.where(id: job_role_ids).pluck(:st_code))
      .where(company_evaluation_id: CompanyEvaluationTemplate.distinct.where(id: company_evaluation_template_ids).pluck(:company_evaluation_id))
  end
end
