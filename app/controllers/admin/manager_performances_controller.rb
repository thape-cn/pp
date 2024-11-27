module Admin
  class ManagerPerformancesController < BaseController
    include ShowPerformance

    private

    def group_level
      "manager_a"
    end

    def group(evaluation_user_capabilities)
      manager_group_a(evaluation_user_capabilities)
    end
  end
end
