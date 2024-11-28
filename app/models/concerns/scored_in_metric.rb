module ScoredInMetric
  extend ActiveSupport::Concern

  included do
    def manager_scored_in_metric
      reverse_5_metric(manager_scored_total_evaluation_score)
    end

    def final_total_score_in_metric
      reverse_5_metric(final_total_evaluation_score)
    end

    def total_score_in_metric
      reverse_5_metric(total_evaluation_score)
    end

    def raw_total_score_in_metric
      reverse_5_metric(raw_total_evaluation_score)
    end

    private

    # Don't forget add JS code reverseScoreInMetric also
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
