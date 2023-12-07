module Admin
  class AuxiliaryPerformancesController < BaseController
    include ShowPerformance

    private

    def group_level
      "auxiliary"
    end

    def group(evaluation_user_capabilities)
      manager_group(evaluation_user_capabilities)
    end
  end
end
