module ExcelExport
  extend ActiveSupport::Concern

  private

  def evaluation_progress_excel_file(evaluation_user_capabilities)
    p = Axlsx::Package.new
    wb = p.workbook

    wb.add_worksheet(name: "evaluation_progress") do |sheet|
      sheet.add_row [I18n.t("evaluation.evaluation_status"),
        I18n.t("evaluation.template_title"),
        I18n.t("user.clerk_code"),
        I18n.t("user.chinese_name"),
        I18n.t("user.company"),
        I18n.t("user.department"),
        I18n.t("user.manager_user")]
      evaluation_user_capabilities.each do |euc|
        values = []
        values << EvaluationUserCapability.form_status_options.invert[euc.form_status]
        values << euc.company_evaluation_template.title
        values << euc.user.clerk_code
        values << euc.user.chinese_name
        values << euc.company
        values << euc.department
        values << euc.manager_user&.chinese_name
        row = sheet.add_row values
        row.cells[2].type = :string
        row.cells[2].value = euc.user.clerk_code # Must overwrite again after setting cell type
      end
    end

    temp_file = Tempfile.new("hello")
    p.serialize temp_file
    temp_file
  end
end
