class CalibrationSessionSaveLog < ApplicationRecord
  SCORE_FIELDS = %w[
    calibration_work_quality
    calibration_work_load
    calibration_work_attitude
    calibration_management_score
    calibration_profession_score
    calibration_management_profession_score
    calibration_performance_score
  ].freeze

  belongs_to :calibration_session
  belongs_to :saved_by, class_name: "User"

  validates :saved_at, presence: true
  validates :group_level, presence: true
  validates :source, presence: true
  validates :scores_snapshot, presence: true

  def self.log!(calibration_session:, saved_by:, source:, group_level:, eucs:)
    create!(
      calibration_session: calibration_session,
      saved_by: saved_by,
      saved_at: Time.current,
      source: source,
      group_level: group_level,
      scores_snapshot: build_scores_snapshot(eucs)
    )
  end

  def self.build_scores_snapshot(eucs)
    eucs.map do |euc|
      snapshot = SCORE_FIELDS.index_with { |field| euc.public_send(field) }
      snapshot.merge(
        "euc_id" => euc.id,
        "user_id" => euc.user_id,
        "management_subtotal_score" => euc.management_subtotal_score,
        "profession_subtotal_score" => euc.profession_subtotal_score
      )
    end
  end
end
