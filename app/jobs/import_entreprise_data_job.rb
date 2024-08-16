require 'csv'
require 'open-uri'

class ImportEntrepriseDataJob < ApplicationJob
  queue_as :default

  def perform(import_file_id)
    Rails.logger.info 'Processing the perform action ...'

    import_file = ImportFile.find(import_file_id)
    Rails.logger.info "Processing import_file #{import_file.inspect} ..."

    import_file.update(status: 'processing')

    Rails.logger.info 'Begin ...'

    begin
      file_content = import_file.file.download
      csv_data = CSV.parse(file_content, headers: true)

      csv_data.each do |row|
        next if row['NIU'].blank?

        location_elements = [row['QUARTIER'], row['COMMUNE'], row['VILLE'], row['DEPARTEMENT'], row['REGION']].compact
        location_combinations = (1..location_elements.size).flat_map { |size| location_elements.combination(size).to_a }

        coordinates = fetch_coordinates(location_combinations)
        create_or_update_entreprise(row, coordinates)
      end

      import_file.update(status: 'completed')
    rescue CSV::MalformedCSVError => e
      import_file.update(status: 'failed')
      Rails.logger.error "Malformed CSV error: #{e.message}"
    rescue StandardError => e
      import_file.update(status: 'failed')
      Rails.logger.error "Failed to import file: #{e.message}"
    end
  end

  private

  def fetch_coordinates(location_combinations)
    location_combinations.each do |combination|
      location_query = combination.join(', ')
      Rails.logger.info "Processing location_query #{location_query.inspect} ..."

      begin
        result = Geocoder.search(location_query, params: { countrycodes: 'CM' }).first
        return result&.coordinates if result&.coordinates.present?
      rescue Geocoder::Error => e
        Rails.logger.error "Geocoder error: #{e.message}"
      end

      sleep(2)
    end
    nil
  end

  def create_or_update_entreprise(row, coordinates)
    latitude, longitude = coordinates || [nil, nil]
    existing_record = Entreprise.find_by(
      niu: row['NIU'],
      forme: row['FORME'],
      raison_sociale_rgpd: row['RAISON_SOCIALE_RGPD'],
      sigle: row['SIGLE'],
      activite: row['ACTIVITE'],
      region: row['REGION'],
      departement: row['DEPARTEMENT'],
      ville: row['VILLE'],
      commune: row['COMMUNE'],
      quartier: row['QUARTIER'],
      lieux_dit: row['LIEUX_DIT'],
      boite_postale: row['BOITE_POSTALE'],
      npc: row['NPC'],
      npc_intitule: row['NPC_INTITULE'],
      isic_refined: row['ISIC_REFINED'],
      isic_1_dig: row['ISIC_1_DIG'],
      isic_2_dig: row['ISIC_2_DIG'],
      isic_3_dig: row['ISIC_3_DIG'],
      isic_4_dig: row['ISIC_4_DIG'],
      isic_intitule: row['ISIC_INTITULE']
    )

    return if existing_record

    Entreprise.create(
      niu: row['NIU'],
      forme: row['FORME'],
      raison_sociale_rgpd: row['RAISON_SOCIALE_RGPD'],
      sigle: row['SIGLE'],
      activite: row['ACTIVITE'],
      region: row['REGION'],
      departement: row['DEPARTEMENT'],
      ville: row['VILLE'],
      commune: row['COMMUNE'],
      quartier: row['QUARTIER'],
      lieux_dit: row['LIEUX_DIT'],
      boite_postale: row['BOITE_POSTALE'],
      npc: row['NPC'],
      npc_intitule: row['NPC_INTITULE'],
      isic_refined: row['ISIC_REFINED'],
      isic_1_dig: row['ISIC_1_DIG'],
      isic_2_dig: row['ISIC_2_DIG'],
      isic_3_dig: row['ISIC_3_DIG'],
      isic_4_dig: row['ISIC_4_DIG'],
      isic_intitule: row['ISIC_INTITULE'],
      latitude:,
      longitude:
    )
  end
end
