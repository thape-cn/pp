class JobRoleEvaluationPerformance < ApplicationRecord
  belongs_to :user
  belongs_to :company_evaluation
  belongs_to :evaluation_user_capability, optional: true

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
