module CP
  class ManagerPerformancesController < BaseController
    include ShowPerformance

    private

    def group_level
      "manager"
    end

    def group(evaluation_user_capabilities)
      manager_group(evaluation_user_capabilities)
    end
  end
end
