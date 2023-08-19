class CalibrationSession < ApplicationRecord
  belongs_to :calibration_template
  belongs_to :owner, class_name: "User"
  has_many :calibration_session_judges, dependent: :destroy
  has_many :calibration_session_users, dependent: :destroy

  def lower_quotas_staff
    populations = {apa_grade_rate: calibration_template.apa_grade_rate, b_grade_rate: calibration_template.b_grade_rate, cd_grade_rate: calibration_template.cd_grade_rate}
    seats = calibration_session_users.size
    CalibrationTemplate.hamilton_method(populations, seats)
  end

  def lower_quotas_manager
    populations = {beyond_standard_rate: calibration_template.beyond_standard_rate, standards_compliant_rate: calibration_template.standards_compliant_rate, below_standard_rate: calibration_template.below_standard_rate}
    seats = calibration_session_users.size
    CalibrationTemplate.hamilton_method(populations, seats)
  end

  def waiting_for_manager_score?
    calibration_session_users.all? do |csu|
      return false if csu.evaluation_user_capability.nil?

      %w[initial self_assessment_done manager_scored].include?(csu.evaluation_user_capability.form_status)
    end && !can_start_calibration?
  end

  def can_start_calibration?
    calibration_session_users.all? do |csu|
      return false if csu.evaluation_user_capability.nil?

      csu.evaluation_user_capability.form_status == "manager_scored"
    end
  end

  def can_start_proofreading?
    if calibration_session_users.count == 1
      csu = calibration_session_users.first
      if csu.new_calibration_session_id.present?
        false
      else
        %w[department_calibrated].include?(csu.evaluation_user_capability.form_status)
      end
    else
      calibration_session_users.all? do |csu|
        return false if csu.evaluation_user_capability.nil?

        %w[department_calibrated].include?(csu.evaluation_user_capability.form_status) ||
          csu.new_calibration_session_id.present?
      end
    end
  end

  def can_undo?
    calibration_session_users.all? do |csu|
      %w[department_calibrated].include?(csu.evaluation_user_capability.form_status) &&
        csu.new_calibration_session_id.blank?
    end
  end

  def proofreading_are_completed?
    calibration_session_users.all? do |csu|
      return false if csu.evaluation_user_capability.nil?

      %w[hr_review_completed data_locked].include?(csu.evaluation_user_capability.form_status) ||
        csu.new_calibration_session_id.present?
    end
  end

  def self.session_status_options
    @_session_status_options ||= {
      I18n.t("calibration.session_status.waiting_manager_score") => "waiting_manager_score",
      I18n.t("calibration.session_status.calibrating") => "calibrating",
      I18n.t("calibration.session_status.proofreading") => "proofreading",
      I18n.t("calibration.session_status.proofreading_completed") => "proofreading_completed",
      I18n.t("calibration.session_status.reconciliation_needed") => "reconciliation_needed"
    }
  end

  def reconcile_session_status
    if can_start_calibration?
      update(session_status: "calibrating")
    elsif proofreading_are_completed? # Need check complete first.
      update(session_status: "proofreading_completed")
    elsif can_start_proofreading?
      update(session_status: "proofreading")
    elsif waiting_for_manager_score?
      update(session_status: "waiting_manager_score")
    else
      update(session_status: "reconciliation_needed")
    end
  end

  def self.reconcile_session_status(company_evaluation_ids)
    CalibrationTemplate.includes(:company_evaluation_template)
      .where(company_evaluation_template: {company_evaluation_id: company_evaluation_ids})
      .each do |calibration_template|
      calibration_template.calibration_sessions.find_each do |calibration_session|
        calibration_session.reconcile_session_status
      end
    end
  end
end
