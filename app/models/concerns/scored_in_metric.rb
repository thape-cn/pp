module ScoredInMetric
  extend ActiveSupport::Concern

  included do
    def manager_scored_in_metric
      if company_evaluation_template.group_level == "manager_b"
        reverse_2d_metric(management_subtotal_score, profession_subtotal_score)
      else
        reverse_5_metric(manager_scored_total_evaluation_score)
      end
    end

    def final_score_in_metric
      if company_evaluation_template.group_level == "manager_b"
        reverse_2d_metric(calibration_management_score, calibration_profession_score)
      else
        reverse_5_metric(final_total_evaluation_score)
      end
    end

    def total_score_in_metric
      if company_evaluation_template.group_level == "manager_b"
        reverse_2d_metric(calibration_management_score || management_subtotal_score, calibration_profession_score || profession_subtotal_score)
      else
        reverse_5_metric(total_evaluation_score)
      end
    end

    def raw_total_score_in_metric
      if company_evaluation_template.group_level == "manager_b"
        reverse_2d_metric(management_subtotal_score, profession_subtotal_score)
      else
        reverse_5_metric(raw_total_evaluation_score)
      end
    end

    private

    def reverse_2d_metric(x, y)
      return "N/A" if x.blank? || y.blank?

      if x >= 4 && y >= 4
        "A+"
      elsif (x >= 2 && y >= 4) || (x >= 4 && y >= 2)
        "A"
      elsif (x >= 4 && y < 2) || (y >= 4 && x < 2) || (x >= 2 && y >= 2)
        "B"
      elsif (x >= 2 && y < 2) || (x < 2 && y >= 2)
        "C"
      else
        "D"
      end
    end

    def reverse_5_metric(score)
      case score
      when 4.5..5
        "A+"
      when 3.5...4.5
        "A"
      when 2.5...3.5
        "B"
      when 1.5...2.5
        "C"
      when 1...1.5
        "D"
      else
        "N/A"
      end
    end
  end
end
