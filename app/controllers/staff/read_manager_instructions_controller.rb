module Staff
  class ReadManagerInstructionsController < BaseController
    def show
    end

    def create
      current_user.update(read_manager_instruction: true)
      company_evaluation_ids = CompanyEvaluation.open_for_user.pluck(:id)
      redirect_to staff_mark_score_path(id: current_user.id, company_evaluation_ids: company_evaluation_ids), notice: t(".success")
    end
  end
end
