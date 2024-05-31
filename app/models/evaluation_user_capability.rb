class EvaluationUserCapability < ApplicationRecord
  MINIMAL_DISPLAY_PEOPLE_NUM = 9
  belongs_to :company_evaluation_template
  belongs_to :user
  belongs_to :job_role
  belongs_to :manager_user, optional: true, class_name: :User
  has_many :job_role_evaluation_performances, dependent: :destroy
  has_many :calibration_session_users, dependent: :destroy
  has_many :euc_form_status_histories, dependent: :destroy
  validates :self_overall_output, length: {minimum: 20}, on: :update
  validates :self_overall_improvement, length: {minimum: 20}, on: :update
  validates :self_overall_plan, length: {minimum: 20}, on: :update
  before_destroy :archive_record
  attr_accessor :deleted_user_id, :deleted_reason

  include Edoc2Upload
  include GroupStaffOrManager

  def not_nil_capability_column_names
    ((attributes.keys.reject { |key| self[key].nil? }) & Capability.all_capability_column_names) - Capability.calibration_column_names
  end

  def pre_work_capability_pct
    work_quality.to_f * (company_evaluation_template.work_quality_pct / 100.0) \
    + work_load.to_f * (company_evaluation_template.work_load_pct / 100.0) \
    + work_attitude.to_f * (company_evaluation_template.work_attitude_pct / 100.0)
  end

  def work_capability_pct
    (calibration_work_quality.nil? ? work_quality : calibration_work_quality).to_f * (company_evaluation_template.work_quality_pct / 100.0) \
    + (calibration_work_load.nil? ? work_load : calibration_work_load).to_f * (company_evaluation_template.work_load_pct / 100.0) \
    + (calibration_work_attitude.nil? ? work_attitude : calibration_work_attitude).to_f * (company_evaluation_template.work_attitude_pct / 100.0)
  end

  def performance_weight_result
    raw_result = if company_evaluation_template.group_level == "auxiliary"
      annual_output # TODO: should general to performance_column_names and add rate to evaluation_role_capabilities
    else
      performance_weight_upload_result
    end
    return 0 if raw_result.nil?

    if raw_result < 2
      1
    elsif raw_result < 4
      3
    elsif raw_result <= 5
      5
    else
      0
    end
  end

  def performance_weight_upload_result
    JobRoleEvaluationPerformance.need_review_job_role_evaluation_performance([self])
      .sum("obj_weight_pct / 100.0 * obj_result")
  end

  def performance_capabilities
    performance_attrs = attributes.select { |key, value| Capability.performance_column_names.include?(key.to_s) && value.present? }
    Capability.where(en_name: performance_attrs.keys)
  end

  def management_capabilities
    management_attrs = attributes.select { |key, value| Capability.management_column_names.include?(key.to_s) && value.present? }
    Capability.where(en_name: management_attrs.keys)
  end

  def management_subtotal_score
    management_attrs = attributes.select { |key, value| Capability.management_column_names.include?(key.to_s) && value.present? }
    total_management_sum = management_attrs.values.sum
    total_management_count = management_attrs.keys.count
    return 0 if total_management_count.zero?
    total_management_sum / total_management_count.to_f
  end

  def professional_capabilities
    profession_attrs = attributes.select { |key, value| Capability.profession_column_names.include?(key.to_s) && value.present? }
    Capability.where(en_name: profession_attrs.keys)
  end

  def profession_subtotal_score
    profession_attrs = attributes.select { |key, value| Capability.profession_column_names.include?(key.to_s) && value.present? }
    total_profession_sum = profession_attrs.values.sum
    total_profession_count = profession_attrs.keys.count
    return 0 if total_profession_count.zero?
    total_profession_sum / total_profession_count.to_f
  end

  def raw_total_evaluation_score
    pre_work_pct_proportion = pre_work_capability_pct.to_f * (company_evaluation_template.pct_proportion / 100.0)
    Rails.logger.debug "pre_work_pct_proportion: #{pre_work_pct_proportion}"

    non_work_proportion_total = company_evaluation_template.management_subtotal_rate + company_evaluation_template.profession_subtotal_rate + company_evaluation_template.performance_subtotal_rate
    Rails.logger.debug "non_work_proportion_total: #{non_work_proportion_total}"
    Rails.logger.debug "company_evaluation_template.rate_proportion: #{company_evaluation_template.rate_proportion}"

    performance_subtotal_pct_proportion = performance_weight_result.to_f * (company_evaluation_template.performance_subtotal_rate / non_work_proportion_total.to_f) * (company_evaluation_template.rate_proportion / 100.0)
    Rails.logger.debug "performance_weight_result: #{performance_weight_result}, performance_subtotal_rate: #{company_evaluation_template.performance_subtotal_rate}, performance_subtotal_pct_proportion: #{performance_subtotal_pct_proportion}"
    management_subtotal_pct_proportion = management_subtotal_score.to_f * (company_evaluation_template.management_subtotal_rate / non_work_proportion_total.to_f) * (company_evaluation_template.rate_proportion / 100.0)
    Rails.logger.debug "management_subtotal_score: #{management_subtotal_score}, management_subtotal_rate: #{company_evaluation_template.management_subtotal_rate}, management_subtotal_pct_proportion: #{management_subtotal_pct_proportion}"
    profession_subtotal_pct_proportion = profession_subtotal_score.to_f * (company_evaluation_template.profession_subtotal_rate / non_work_proportion_total.to_f) * (company_evaluation_template.rate_proportion / 100.0)
    Rails.logger.debug "profession_subtotal_score: #{profession_subtotal_score}, profession_subtotal_rate: #{company_evaluation_template.profession_subtotal_rate}, profession_subtotal_pct_proportion: #{profession_subtotal_pct_proportion}"

    pre_work_pct_proportion.to_f + management_subtotal_pct_proportion.to_f + profession_subtotal_pct_proportion.to_f + performance_subtotal_pct_proportion.to_f
  end

  def total_evaluation_score
    work_pct_proportion = work_capability_pct.to_f * (company_evaluation_template.pct_proportion / 100.0)
    # Rails.logger.debug "work_pct_proportion: #{work_pct_proportion}"

    non_work_proportion_total = company_evaluation_template.management_subtotal_rate + company_evaluation_template.profession_subtotal_rate + company_evaluation_template.performance_subtotal_rate
    # Rails.logger.debug "non_work_proportion_total: #{non_work_proportion_total}"

    performance_subtotal_pct_proportion = (calibration_performance_score.nil? ? performance_weight_result : calibration_performance_score).to_f * (company_evaluation_template.performance_subtotal_rate / non_work_proportion_total.to_f) * (company_evaluation_template.rate_proportion / 100.0)
    # Rails.logger.debug "performance_subtotal_pct_proportion: #{performance_subtotal_pct_proportion}"

    if calibration_management_profession_score.nil?
      management_subtotal_pct_proportion = management_subtotal_score.to_f * (company_evaluation_template.management_subtotal_rate / non_work_proportion_total.to_f) * (company_evaluation_template.rate_proportion / 100.0)
      # Rails.logger.debug "management_subtotal_pct_proportion: #{management_subtotal_pct_proportion}"

      profession_subtotal_pct_proportion = profession_subtotal_score.to_f * (company_evaluation_template.profession_subtotal_rate / non_work_proportion_total.to_f) * (company_evaluation_template.rate_proportion / 100.0)
      # Rails.logger.debug "profession_subtotal_pct_proportion: #{profession_subtotal_pct_proportion}"

      work_pct_proportion.to_f + management_subtotal_pct_proportion.to_f + profession_subtotal_pct_proportion.to_f + performance_subtotal_pct_proportion.to_f
    else
      management_profession_subtotal_pct_proportion = calibration_management_profession_score.to_f * ((company_evaluation_template.management_subtotal_rate + company_evaluation_template.profession_subtotal_rate) / non_work_proportion_total.to_f) * (company_evaluation_template.rate_proportion / 100.0)
      # Rails.logger.debug "management_profession_subtotal_pct_proportion: #{management_profession_subtotal_pct_proportion}"

      work_pct_proportion.to_f + management_profession_subtotal_pct_proportion.to_f + performance_subtotal_pct_proportion.to_f
    end
  end

  def initial_capability_score_filling
    columns_to_update_nil = Capability.all_capability_column_names.each_with_object({}) { |en_name, hash| hash[en_name] = nil }
    update_columns(columns_to_update_nil.merge(manager_scored_total_evaluation_score: nil, final_total_evaluation_score: nil))
    columns_to_update_zero = job_role.evaluation_role&.capabilities&.each_with_object({}) { |capability, hash| hash[capability.en_name] = 0 }
    if columns_to_update_zero.present?
      update_columns(columns_to_update_zero)
    else
      update_columns(capability_columns_all_null: true)
    end
  end

  def self.form_status_options
    {
      I18n.t("evaluation.form_status.initial") => "initial",
      I18n.t("evaluation.form_status.self_assessment_done") => "self_assessment_done",
      I18n.t("evaluation.form_status.manager_scored") => "manager_scored",
      I18n.t("evaluation.form_status.department_calibrated") => "department_calibrated",
      I18n.t("evaluation.form_status.hr_review_completed") => "hr_review_completed",
      I18n.t("evaluation.form_status.data_locked") => "data_locked"
    }
  end

  def update_form_status_to(future_form_status, perform_user)
    previous_form_status = form_status
    update_result = update(form_status: future_form_status)
    euc_form_status_histories.create(previous_form_status: previous_form_status, form_status: future_form_status, user_id: perform_user.id)
    update_result
  end

  private

  def archive_record
    ArchivedEvaluationUserCapability.create(
      attributes.except("final_total_evaluation_grade", "edoc_guid", "edoc_file_id").merge({deleted_time: Time.current, deleted_user_id: deleted_user_id, deleted_reason: deleted_reason})
    )
  end
end
