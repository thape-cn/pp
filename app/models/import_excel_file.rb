class ImportExcelFile < ApplicationRecord
  belongs_to :user
  belongs_to :company_evaluation
  has_one_attached :excel_file

  def self.import_type_options
    {
      I18n.t("import_exports.import_type.new_evaluation") => "new_evaluation"
    }
  end
end
