module Admin
  class AuxiliaryPerformancesController < BaseController
    include ShowPerformance

    private

    def group_level
      "auxiliary"
    end
  end
end
