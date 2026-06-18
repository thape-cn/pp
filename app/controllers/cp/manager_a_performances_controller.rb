module CP
  class ManagerAPerformancesController < BaseController
    include ShowPerformance

    private

    def group_level
      "manager_a"
    end
  end
end
