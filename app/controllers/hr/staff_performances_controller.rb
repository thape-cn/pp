module HR
  class StaffPerformancesController < BaseController
    include StaffManagerGroup

    def index
      evaluation_user_capabilities = policy_scope(EvaluationUserCapability)
      @evaluation_user_capabilities_group = staff_group(evaluation_user_capabilities)
    end
  end
end
