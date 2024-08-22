class AddManyFieldsToEntreprises < ActiveRecord::Migration[7.2]
  def change
    add_column :entreprises, :isic_1_dig_description, :string
    add_column :entreprises, :isic_2_dig_description, :string
    add_column :entreprises, :isic_3_dig_description, :string
    add_column :entreprises, :isic_4_dig_description, :string
    add_column :entreprises, :isic_refined_intitule, :string
  end
end
