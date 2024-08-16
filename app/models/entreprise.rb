class Entreprise < ApplicationRecord
    belongs_to :category_refined, class_name: 'Category', foreign_key: 'isic_refined', optional: true
    belongs_to :category_1_dig, class_name: 'Category', foreign_key: 'isic_1_dig', optional: true
    belongs_to :category_2_dig, class_name: 'Category', foreign_key: 'isic_2_dig', optional: true
    belongs_to :category_3_dig, class_name: 'Category', foreign_key: 'isic_3_dig', optional: true
    belongs_to :category_4_dig, class_name: 'Category', foreign_key: 'isic_4_dig', optional: true
  
    scope :with_coordinates, -> { where.not(latitude: nil, longitude: nil) }
end
