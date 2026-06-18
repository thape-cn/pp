module UpdateSessionGroup
  extend ActiveSupport::Concern

  private

  def update_calibration_group(calibration, company_evaluation_template)
    return if calibration.blank?

    calibration.each do |square_key, calibration_square|
      update_person_by_square(calibration_square) do |euc|
        euc.update(company_evaluation_template.calibration_attributes_for_square(square_key, euc))
      end
    end
  end

  def update_person_by_square(calibration_square)
    return if calibration_square.blank?

    calibration_square.each do |item|
      yield EvaluationUserCapability.find(item["id"])
    end
  end
end
