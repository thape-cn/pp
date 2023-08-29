module PerformancesHelper
  def display_evaluation_user_capabilities(evaluation_user_capabilities)
    return nil unless evaluation_user_capabilities.present?

    evaluation_user_capabilities.take(9).each do |euc|
      link_url = case euc.company_evaluation_template.group_level
      when "manager"
        hr_manager_performance_path(id: euc.id)
      else
        hr_staff_performance_path(id: euc.id)
      end
      concat(content_tag(:span, class: "btn btn-light rounded-pill m-1") do
        concat(euc.user.chinese_name)
        concat(link_to(euc.total_evaluation_score, link_url, class: "text-decoration-none link-light badge ms-1 rounded-pill bg-info", data: {controller: "modal", action: "modal#click", "modal-page-reload-value": false}))
      end)
    end
    nil # already concat the output.
  end
end