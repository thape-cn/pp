module HR
  class StaffPerformancesController < BaseController
    include ShowPerformance

    private

    def group_level
      "staff"
    end

    def group(evaluation_user_capabilities)
      staff_group(evaluation_user_capabilities)
    end
  end
end
