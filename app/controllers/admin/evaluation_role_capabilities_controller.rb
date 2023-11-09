module Admin
  class EvaluationRoleCapabilitiesController < BaseController
    after_action :verify_authorized
    before_action :set_evaluation_role_capability, only: %i[update]

    def update
      @evaluation_role_capability.update(evaluation_role_capability_params)
      head :no_content
    end

    private

    def set_evaluation_role_capability
      @evaluation_role_capability = authorize EvaluationRoleCapability.find(params[:id])
    end

    def evaluation_role_capability_params
      params.require(:evaluation_role_capability).permit(:erc_description)
    end
  end
end
