module UpdateSessionGroup
  extend ActiveSupport::Concern

  private

  def update_staff_group(calibration)
    update_person_by_square(calibration["11"]) { |euc| euc.update(calibration_work_quality: 1, calibration_work_load: 5, calibration_work_attitude: euc.work_attitude) }
    update_person_by_square(calibration["12"]) { |euc| euc.update(calibration_work_quality: 3, calibration_work_load: 5, calibration_work_attitude: euc.work_attitude) }
    update_person_by_square(calibration["13"]) { |euc| euc.update(calibration_work_quality: 5, calibration_work_load: 5, calibration_work_attitude: euc.work_attitude) }
    update_person_by_square(calibration["21"]) { |euc| euc.update(calibration_work_quality: 1, calibration_work_load: 3, calibration_work_attitude: euc.work_attitude) }
    update_person_by_square(calibration["22"]) { |euc| euc.update(calibration_work_quality: 3, calibration_work_load: 3, calibration_work_attitude: euc.work_attitude) }
    update_person_by_square(calibration["23"]) { |euc| euc.update(calibration_work_quality: 5, calibration_work_load: 3, calibration_work_attitude: euc.work_attitude) }
    update_person_by_square(calibration["31"]) { |euc| euc.update(calibration_work_quality: 1, calibration_work_load: 1, calibration_work_attitude: euc.work_attitude) }
    update_person_by_square(calibration["32"]) { |euc| euc.update(calibration_work_quality: 3, calibration_work_load: 1, calibration_work_attitude: euc.work_attitude) }
    update_person_by_square(calibration["33"]) { |euc| euc.update(calibration_work_quality: 5, calibration_work_load: 1, calibration_work_attitude: euc.work_attitude) }
  end

  def update_manager_group_a(calibration)
    update_person_by_square(calibration["11"]) { |euc| euc.update(calibration_management_profession_score: 1, calibration_performance_score: 5) }
    update_person_by_square(calibration["12"]) { |euc| euc.update(calibration_management_profession_score: 3, calibration_performance_score: 5) }
    update_person_by_square(calibration["13"]) { |euc| euc.update(calibration_management_profession_score: 5, calibration_performance_score: 5) }
    update_person_by_square(calibration["21"]) { |euc| euc.update(calibration_management_profession_score: 1, calibration_performance_score: 3) }
    update_person_by_square(calibration["22"]) { |euc| euc.update(calibration_management_profession_score: 3, calibration_performance_score: 3) }
    update_person_by_square(calibration["23"]) { |euc| euc.update(calibration_management_profession_score: 5, calibration_performance_score: 3) }
    update_person_by_square(calibration["31"]) { |euc| euc.update(calibration_management_profession_score: 1, calibration_performance_score: 1) }
    update_person_by_square(calibration["32"]) { |euc| euc.update(calibration_management_profession_score: 3, calibration_performance_score: 1) }
    update_person_by_square(calibration["33"]) { |euc| euc.update(calibration_management_profession_score: 5, calibration_performance_score: 1) }
  end

  def update_manager_group_b(calibration)
    update_person_by_square(calibration["11"]) { |euc| euc.update(calibration_management_score: 1, calibration_profession_score: 5) }
    update_person_by_square(calibration["12"]) { |euc| euc.update(calibration_management_score: 3, calibration_profession_score: 5) }
    update_person_by_square(calibration["13"]) { |euc| euc.update(calibration_management_score: 5, calibration_profession_score: 5) }
    update_person_by_square(calibration["21"]) { |euc| euc.update(calibration_management_score: 1, calibration_profession_score: 3) }
    update_person_by_square(calibration["22"]) { |euc| euc.update(calibration_management_score: 3, calibration_profession_score: 3) }
    update_person_by_square(calibration["23"]) { |euc| euc.update(calibration_management_score: 5, calibration_profession_score: 3) }
    update_person_by_square(calibration["31"]) { |euc| euc.update(calibration_management_score: 1, calibration_profession_score: 1) }
    update_person_by_square(calibration["32"]) { |euc| euc.update(calibration_management_score: 3, calibration_profession_score: 1) }
    update_person_by_square(calibration["33"]) { |euc| euc.update(calibration_management_score: 5, calibration_profession_score: 1) }
  end

  def update_person_by_square(calibration_square)
    return if calibration_square.nil?

    calibration_square.each do |item|
      euc = EvaluationUserCapability.find item["id"]
      yield euc
    end
  end
end
