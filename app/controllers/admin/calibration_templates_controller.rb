module Admin
  class CalibrationTemplatesController < BaseController
    after_action :verify_authorized, only: %i[new create]
    before_action :set_company_evaluation, only: %i[new create edit update destroy confirm_destroy]
    before_action :set_company_evaluation_template, only: %i[new create edit update destroy confirm_destroy]
    before_action :set_calibration_template, only: %i[edit update destroy confirm_destroy]

    def new
      @calibration_template = authorize CalibrationTemplate.new(company_evaluation_template_id: @company_evaluation_template.id)
      render layout: false
    end

    def create
      authorize CalibrationTemplate.create(calibration_template_params.merge(company_evaluation_template_id: @company_evaluation_template.id))
    end

    def edit
      render layout: false
    end

    def update
      @calibration_template.update(calibration_template_params)
    end

    def confirm_destroy
      render layout: false
    end

    def destroy
      return if @calibration_template.calibration_sessions.present?

      @calibration_template.destroy
    end

    private

    def calibration_template_params
      params.require(:calibration_template)
        .permit(:template_name, :apa_grade_rate, :b_grade_rate, :cd_grade_rate,
          :below_standard_rate, :standards_compliant_rate, :beyond_standard_rate,
          :enforce_distribute, :enforce_highest_only)
    end

    def set_company_evaluation
      @company_evaluation = authorize CompanyEvaluation.find(params[:company_evaluation_id])
    end

    def set_company_evaluation_template
      @company_evaluation_template = authorize @company_evaluation.company_evaluation_templates.find(params[:template_id])
    end

    def set_calibration_template
      @calibration_template = authorize @company_evaluation_template.calibration_templates.find(params[:id])
    end
  end
end
