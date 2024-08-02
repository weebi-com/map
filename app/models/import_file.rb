class ImportFile < ApplicationRecord
  has_one_attached :file
  # validates :country, presence: true

end
