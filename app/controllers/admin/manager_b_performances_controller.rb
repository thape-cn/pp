module Admin
  class ManagerBPerformancesController < BaseController
    include ShowPerformance

    private

    def group_level
      "manager_b"
    end

    def group(evaluation_user_capabilities)
      manager_group_b(evaluation_user_capabilities)
    end
  end
end
