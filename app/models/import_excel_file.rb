class ImportExcelFile < ApplicationRecord
  belongs_to :user
  belongs_to :company_evaluation
  has_many :import_excel_file_messages
  has_one_attached :excel_file

  def self.import_type_options
    {
      I18n.t("import_exports.import_type.new_evaluation") => "new_evaluation",
      I18n.t("import_exports.import_type.new_calibration_session") => "new_calibration_session",
      I18n.t("import_exports.import_type.new_performance") => "new_performance"
    }
  end

  def self.file_status_options
    {
      I18n.t("import_exports.file_status.do_validating") => "do_validating",
      I18n.t("import_exports.file_status.validate_failed") => "validate_failed",
      I18n.t("import_exports.file_status.validated") => "validated",
      I18n.t("import_exports.file_status.do_importing") => "do_importing",
      I18n.t("import_exports.file_status.imported") => "imported"
    }
  end
end
