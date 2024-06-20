module PerformancesHelper
  def display_evaluation_user_capabilities(evaluation_user_capabilities)
    return nil unless evaluation_user_capabilities.present?

    evaluation_user_capabilities.take(9).each do |euc|
      link_url = case euc.company_evaluation_template.group_level
      when "manager"
        if current_user.admin?
          admin_manager_performance_path(id: euc.id)
        elsif current_user.corp_president?
          cp_manager_performance_path(id: euc.id)
        else
          hr_manager_performance_path(id: euc.id)
        end
      when "auxiliary"
        if current_user.admin?
          admin_auxiliary_performance_path(id: euc.id)
        elsif current_user.corp_president?
          cp_auxiliary_performance_path(id: euc.id)
        else
          hr_auxiliary_performance_path(id: euc.id)
        end
      else
        if current_user.admin?
          admin_staff_performance_path(id: euc.id)
        elsif current_user.corp_president?
          cp_staff_performance_path(id: euc.id)
        else
          hr_staff_performance_path(id: euc.id)
        end
      end
      concat(content_tag(:span, class: "btn btn-light rounded-pill m-1") do
        concat(euc.user.chinese_name)
        concat(link_to(format("%.1f", euc.raw_total_evaluation_score.round(1)), link_url, class: "text-decoration-none link-light badge ms-1 rounded-pill bg-info", data: {controller: "modal", action: "modal#click", "modal-page-reload-value": false}))
      end)
    end
    nil # already concat the output.
  end
end
