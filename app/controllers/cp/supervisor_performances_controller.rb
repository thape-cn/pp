module CP
  class SupervisorPerformancesController < BaseController
    include ShowPerformance

    private

    def group_level
      "supervisor"
    end
  end
end
