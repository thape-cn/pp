class CreateCalibrationSessionParticipants < ActiveRecord::Migration[7.1]
  def change
    create_table :calibration_session_judges do |t|
      t.references :calibration_session, null: false, foreign_key: true
      t.references :judge, null: false, foreign_key: false

      t.timestamps
    end
    create_table :calibration_session_users do |t|
      t.references :calibration_session, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
