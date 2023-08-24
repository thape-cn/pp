module HR
  class ManagerPerformancesController < BaseController
    include StaffManagerGroup

    def index
      evaluation_user_capabilities = policy_scope(EvaluationUserCapability)
      @evaluation_user_capabilities_group = manager_group(evaluation_user_capabilities)
    end
  end
end
