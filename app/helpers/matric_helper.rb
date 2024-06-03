module MatricHelper
  def to_metrics_value(score)
    return score if score.is_a?(Integer)

    str_score = score.to_s
    if str_score.include?(".0")
      score.to_i
    else
      score.to_f
    end
  end

  # List all available matric names
  def all_metrics
    {
      "三档量表" => "grading_3_metric",
      "五档量表" => "grading_5_metric",
      "九档量表" => "grading_9_metric"
    }
  end

  def grading_3_metric
    {
      "超出标准" => 5,
      "符合标准" => 3,
      "低于标准" => 1
    }
  end

  def grading_5_metric
    {
      "A+" => 5,
      "A" => 4,
      "B" => 3,
      "C" => 2,
      "D" => 1
    }
  end

  def grading_9_metric
    {
      "5-优秀" => 5,
      "4.5" => 4.5,
      "4" => 4,
      "3.5" => 3.5,
      "3-合格" => 3,
      "2.5" => 2.5,
      "2" => 2,
      "1.5" => 1.5,
      "1-差" => 1
    }
  end

  def reverse_total_evaluation_score_metrics
    {
      "五档量表" => "reverse_5_metric"
    }
  end

  # Don't forget add JS code reverseScoreInMatric also
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
