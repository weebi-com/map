class CreateDataActivities < ActiveRecord::Migration[7.1]
  def change
    create_table :data_activities do |t|
      t.string :activite_principale
      t.string :vente_boisson
      t.string :regime
      t.string :boite_postale
      t.string :telephone
      t.string :tel1
      t.string :tel2
      t.string :tel3
      t.string :forme
      t.string :cri
      t.string :centre_de_rattachement
      t.string :region_admin
      t.string :dept
      t.string :ville
      t.string :commune
      t.string :quartier
      t.string :lieux_dit
      t.integer :exercice
      t.integer :mois
      t.string :etatniu
      t.string :idclasse_activite
      t.string :ind
      t.float :lat
      t.float :lng

      t.timestamps
    end
  end
end
