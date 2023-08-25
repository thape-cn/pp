module PerformancesHelper
  def display_evaluation_user_capabilities(evaluation_user_capabilities)
    return nil unless evaluation_user_capabilities.present?

    evaluation_user_capabilities.take(9).each do |euc|
      concat(content_tag(:span, class: "btn btn-light rounded-pill m-1") do
        concat(euc.user.chinese_name)
        concat(content_tag(:span, euc.total_evaluation_score, class: "badge ms-1 rounded-pill bg-info"))
      end)
    end
    nil # already concat the output.
  end
end
