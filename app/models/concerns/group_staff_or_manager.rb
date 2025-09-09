module GroupStaffOrManager
  extend ActiveSupport::Concern

  included do
    def group_of_staff_work_load
      return 3 if work_load.nil?

      @group_of_staff_work_load ||= vertical_score_to_column_square(calibration_work_load.nil? ? work_load : calibration_work_load)
    end

    def group_of_staff_work_quality_and_work_attitude
      @group_of_staff_work_quality_and_work_attitude ||= begin
        total_percentage = company_evaluation_template.work_quality_pct + company_evaluation_template.work_attitude_pct

        work_quality_part = (calibration_work_quality.nil? ? work_quality : calibration_work_quality).to_f \
          * (company_evaluation_template.work_quality_pct / total_percentage.to_f)
        work_attitude_part = (calibration_work_attitude.nil? ? work_attitude : calibration_work_attitude).to_f \
          * (company_evaluation_template.work_attitude_pct / total_percentage.to_f)

        work_quality_and_work_attitude = work_quality_part + work_attitude_part
        Rails.logger.info "work_quality_and_work_attitude: #{work_quality_and_work_attitude} euc_id: #{id}"
        horizontal_score_to_row_square(work_quality_and_work_attitude)
      end
    end

    def group_of_manager_performance
      @group_of_manager_performance ||= begin
        performance_score = calibration_performance_score.present? ? calibration_performance_score : performance_weight_result
        vertical_score_to_column_square(performance_score)
      end
    end

    def group_of_manager_management_profession
      @group_of_manager_management_profession ||= begin
        total_rate = company_evaluation_template.management_subtotal_rate + company_evaluation_template.profession_subtotal_rate

        management_part = management_subtotal_score.to_f * (company_evaluation_template.management_subtotal_rate / total_rate.to_f)
        profession_part = profession_subtotal_score.to_f * (company_evaluation_template.profession_subtotal_rate / total_rate.to_f)

        management_profession_score = calibration_management_profession_score.present? ? calibration_management_profession_score : management_part + profession_part

        Rails.logger.info "management_profession_score: #{management_profession_score} euc_id: #{id}"
        horizontal_score_to_row_square(management_profession_score)
      end
    end

    def group_of_manager_only_management
      @group_of_manager_only_management ||= begin
        management_score = calibration_management_score.present? ? calibration_management_score : management_subtotal_score.to_f
        Rails.logger.info "management_only_score: #{management_score} euc_id: #{id}"
        horizontal_score_to_row_square(management_score)
      end
    end

    def group_of_manager_only_profession
      @group_of_manager_only_profession ||= begin
        profession_score = calibration_profession_score.present? ? calibration_profession_score : profession_subtotal_score.to_f
        Rails.logger.info "profession_only_score: #{profession_score} euc_id: #{id}"
        vertical_score_to_column_square(profession_score)
      end
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
