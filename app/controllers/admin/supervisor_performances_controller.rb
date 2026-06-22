module Admin
  class SupervisorPerformancesController < BaseController
    include ShowPerformance

    private

    def group_level
      "supervisor"
    end
  end
end
