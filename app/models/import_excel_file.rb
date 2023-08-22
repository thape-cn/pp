class ImportExcelFile < ApplicationRecord
  belongs_to :user
  has_one_attached :excel_file

  def self.import_type_options
    {
      I18n.t("form.import_type.new_evaluation") => "new_evaluation"
    }
  end
end
