require 'csv'
require 'open-uri'

class ImportDataActivityDataJob < ApplicationJob
  queue_as :default

  def perform(import_file_id, country)
    Rails.logger.info "Processing the perform action ..."

    import_file = ImportFile.find(import_file_id)
    Rails.logger.info "Processing import_file #{import_file.inspect} ..."

    Rails.logger.info "Country: #{country.inspect} ..."

    import_file.update(status: 'processing')

    Rails.logger.info "Processing import_file #{import_file.inspect} ..."

    begin
      Rails.logger.info "Begin ..."

      # Télécharger le contenu du fichier
      file_content = import_file.file.download

      # Analyser le contenu CSV en mémoire avec les en-têtes
      csv_data = CSV.parse(file_content, headers: true)

      csv_data.each do |row|
        Rails.logger.info "Processing CSV #{row.inspect} ..."

        next if row['ACTIVITE_PRINCIPALE'].blank?  # Ignorer les lignes vides

        # Combiner la ville et le pays pour la recherche
        # location_query = "#{country}, #{row['VILLE']}"
        location_query = "#{row['VILLE']}"
        coordinates = Geocoder.search(location_query).first&.coordinates
        Rails.logger.info "Processing coordinates #{coordinates.inspect} ..."

        if coordinates
          lat, lng = coordinates
        else
          lat, lng = nil, nil
        end

        Rails.logger.info "Processing lat & lng #{lat} #{lng} ..."
        Rails.logger.info "Processing row['ACTIVITE_PRINCIPALE'] #{row['ACTIVITE_PRINCIPALE']}  ..."

        # Vérifiez si l'enregistrement existe déjà
        existing_record = DataActivity.find_by(
          activite_principale: row['ACTIVITE_PRINCIPALE'],
          vente_boisson: row['VENTE_BOISSON'],
          regime: row['REGIME'],
          boite_postale: row['BOITE_POSTALE'],
          telephone: row['TELEPHONE'],
          tel1: row['TEL1'],
          tel2: row['TEL2'],
          tel3: row['TEL3'],
          forme: row['FORME'],
          cri: row['CRI'],
          centre_de_rattachement: row['CENTRE_DE_RATTACHEMENT'],
          region_admin: row['REGION_ADMIN'],
          dept: row['DEPT'],
          ville: row['VILLE'],
          commune: row['COMMUNE'],
          quartier: row['QUARTIER'],
          lieux_dit: row['LIEUX_DIT'],
          exercice: row['EXERCICE'],
          mois: row['MOIS'],
          etatniu: row['ETATNIU'],
          idclasse_activite: row['IDCLASSE_ACTIVITE'],
          ind: row['IND'],
          pays: country
        )

        unless existing_record
          # Créer une nouvelle entrée dans DataActivity avec les données de la ligne CSV
          DataActivity.create!(
            activite_principale: row['ACTIVITE_PRINCIPALE'],
            vente_boisson: row['VENTE_BOISSON'],
            regime: row['REGIME'],
            boite_postale: row['BOITE_POSTALE'],
            telephone: row['TELEPHONE'],
            tel1: row['TEL1'],
            tel2: row['TEL2'],
            tel3: row['TEL3'],
            forme: row['FORME'],
            cri: row['CRI'],
            centre_de_rattachement: row['CENTRE_DE_RATTACHEMENT'],
            region_admin: row['REGION_ADMIN'],
            dept: row['DEPT'],
            ville: row['VILLE'],
            commune: row['COMMUNE'],
            quartier: row['QUARTIER'],
            lieux_dit: row['LIEUX_DIT'],
            exercice: row['EXERCICE'],
            mois: row['MOIS'],
            etatniu: row['ETATNIU'],
            idclasse_activite: row['IDCLASSE_ACTIVITE'],
            ind: row['IND'],
            lat: lat,
            lng: lng,
            pays: country
          )
        end
      end

      # Mise à jour du statut du fichier d'importation à 'completed'
      import_file.update(status: 'completed')
      ActionCable.server.broadcast('notifications_channel', { message: 'Import completed successfully'})
    rescue CSV::MalformedCSVError => e
      # Gestion des erreurs liées au format du fichier CSV
      import_file.update(status: 'failed')
      Rails.logger.error "Failed to import file: #{e.message}"
      ActionCable.server.broadcast('notifications_channel', {message: "CSV file format error: #{e.message}"})
    rescue StandardError => e
      # Gestion des autres erreurs
      import_file.update(status: 'failed')
      Rails.logger.error "Failed to import file: #{e.message}"
      ActionCable.server.broadcast('notifications_channel', {message: "Import failed: #{e.message}"})
    end
  end
end
