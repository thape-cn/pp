module Admin
  class ManagerBPerformancesController < BaseController
    include ShowPerformance

    private

    def group_level
      "manager_b"
    end
  end
end
