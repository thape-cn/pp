class ImportExcelFile < ApplicationRecord
  belongs_to :user
  has_one_attached :excel_file
end
