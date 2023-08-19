module GroupStaffOrManager
  extend ActiveSupport::Concern

  included do
    def group_of_staff_work_load
      return 3 if work_load.nil?

      vertical_score_to_column_square(calibration_work_load.nil? ? work_load : calibration_work_load)
    end

    def group_of_staff_work_quality_and_work_attitude
      total_percentage = company_evaluation_template.work_quality_pct + company_evaluation_template.work_attitude_pct

      work_quality_part = (calibration_work_quality.nil? ? work_quality : calibration_work_quality).to_f \
        * (company_evaluation_template.work_quality_pct / total_percentage.to_f)
      work_attitude_part = (calibration_work_attitude.nil? ? work_attitude : calibration_work_attitude).to_f \
        * (company_evaluation_template.work_attitude_pct / total_percentage.to_f)

      work_quality_and_work_attitude = work_quality_part + work_attitude_part
      horizontal_score_to_row_square(work_quality_and_work_attitude)
    end

    def group_of_manager_performance
      performance_score = calibration_performance_score.present? ? calibration_performance_score : performance_weight_result
      vertical_score_to_column_square(performance_score)
    end

    def group_of_manager_capability
      total_rate = company_evaluation_template.management_subtotal_rate + company_evaluation_template.profession_subtotal_rate

      management_part = management_subtotal_score.to_f * (company_evaluation_template.management_subtotal_rate / total_rate.to_f)
      profession_part = profession_subtotal_score.to_f * (company_evaluation_template.profession_subtotal_rate / total_rate.to_f)

      management_profession_score = calibration_management_profession_score.present? ? calibration_management_profession_score : management_part + profession_part

      horizontal_score_to_row_square(management_profession_score)
    end

    private

    def horizontal_score_to_row_square(score)
      if score >= 4
        3
      elsif score >= 2
        2
      elsif score >= 1
        1
      else
        1 # because only 3x3
      end
    end

    def vertical_score_to_column_square(score)
      if score >= 4
        1
      elsif score >= 2
        2
      elsif score >= 1
        3
      else
        3 # because only 3x3
      end
    end
  end
end
