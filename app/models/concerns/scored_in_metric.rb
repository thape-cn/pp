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

    #      x<2   2≤x<4   x≥4
    # y≥4   B      A     A+
    # 2≤y<4 C      B      A
    # y<2   D      C      B
    def reverse_2d_metric(x, y)
      return "N/A" if x.blank? || y.blank?

      if y >= 4
        if x >= 4
          "A+"
        elsif x >= 2
          "A"
        else
          "B"
        end
      elsif y >= 2
        if x >= 4
          "A"
        elsif x >= 2
          "B"
        else
          "C"
        end
      else
        if x >= 4
          "B"
        elsif x >= 2
          "C"
        else
          "D"
        end
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
