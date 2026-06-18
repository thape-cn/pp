module Admin
  class StaffPerformancesController < BaseController
    include ShowPerformance

    private

    def group_level
      "staff"
    end
  end
end
