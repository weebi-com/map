class CreateEntreprises < ActiveRecord::Migration[7.2]
  def change
    create_table :entreprises do |t|
      t.string :niu
      t.string :forme
      t.string :raison_sociale_rgpd
      t.string :sigle
      t.string :activite
      t.string :region
      t.string :departement
      t.string :ville
      t.string :commune
      t.string :quartier
      t.string :lieux_dit
      t.string :boite_postale
      t.integer :npc
      t.string :npc_intitule
      t.integer :isic_refined
      t.integer :isic_1_dig
      t.integer :isic_2_dig
      t.string :isic_3_dig
      t.string :isic_4_dig
      t.string :isic_intitule
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
