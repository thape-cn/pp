module Admin
  class CalibrationTemplatesController < BaseController
    after_action :verify_authorized, except: :index
    after_action :verify_policy_scoped, only: :index
    before_action :set_company_evaluation
    before_action :set_calibration_template, only: %i[edit update destroy confirm_destroy]
    before_action :set_available_company_evaluation_templates, only: %i[new edit]
    before_action :set_breadcrumbs, if: -> { request.format.html? }

    def index
      @calibration_templates = policy_scope(CalibrationTemplate)
        .joins(:company_evaluation_templates)
        .where(company_evaluation_templates: {company_evaluation_id: @company_evaluation.id})
        .includes(:company_evaluation_templates)
        .distinct
        .order(:template_name)
      add_to_breadcrumbs t(".breadcrumb_title", title: @company_evaluation.title)
      set_meta_tags(title: t(".breadcrumb_title", title: @company_evaluation.title))
    end

    def new
      @calibration_template = authorize CalibrationTemplate.new
      render layout: false
    end

    def create
      @calibration_template = CalibrationTemplate.new(calibration_template_attributes)
      @calibration_template.company_evaluation_templates = selected_company_evaluation_templates
      authorize @calibration_template
      @calibration_template.save
    end

    def edit
      render layout: false
    end

    def update
      other_company_templates = @calibration_template.company_evaluation_templates
        .where.not(company_evaluation_id: @company_evaluation.id)
      @calibration_template.assign_attributes(calibration_template_attributes)
      @calibration_template.company_evaluation_templates = other_company_templates + selected_company_evaluation_templates
      @calibration_template.save
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
          :enforce_distribute, :enforce_highest_only,
          company_evaluation_template_ids: [])
    end

    def calibration_template_attributes
      calibration_template_params.except(:company_evaluation_template_ids)
    end

    def selected_company_evaluation_templates
      @company_evaluation.company_evaluation_templates
        .where(id: calibration_template_params[:company_evaluation_template_ids])
        .to_a
    end

    def set_company_evaluation
      @company_evaluation = authorize CompanyEvaluation.find(params[:company_evaluation_id])
    end

    def set_calibration_template
      @calibration_template = authorize @company_evaluation.calibration_templates.find(params[:id])
    end

    def set_available_company_evaluation_templates
      @available_company_evaluation_templates = @company_evaluation.company_evaluation_templates.order(:title)
    end

    def set_breadcrumbs
      @_breadcrumbs = [
        {text: t("layouts.sidebars.admin.header"),
         link: root_path},
        {text: t("layouts.sidebars.admin.company_evaluation_templates"),
         link: admin_company_evaluation_templates_path(company_evaluation_id: @company_evaluation.id)},
        {text: t("admin.calibration_templates.index.title"),
         link: admin_company_evaluation_calibration_templates_path(company_evaluation_id: @company_evaluation.id)}
      ]
    end
  end
end
