require "csv"
require "open-uri"

class ImportEntrepriseDataJob < ApplicationJob
  queue_as :default

  def perform(import_file_id)
    Rails.logger.info "Processing the perform action ..."

    import_file = ImportFile.find(import_file_id)
    Rails.logger.info "Processing import_file #{import_file.inspect} ..."

    import_file.update(status: "processing")

    Rails.logger.info "Begin ..."

    begin
      file_content = import_file.file.download
      csv_data = CSV.parse(file_content, headers: true)

      csv_data.each do |row|
        next if row["NIU"].blank? || row["niu"].blank?

        create_or_update_entreprise(row)
      end

      import_file.update(status: "completed")
    rescue CSV::MalformedCSVError => e
      import_file.update(status: "failed")
      Rails.logger.error "Malformed CSV error: #{e.message}"
    rescue StandardError => e
      import_file.update(status: "failed")
      Rails.logger.error "Failed to import file: #{e.message}"
    end
  end

  private

  def fetch_coordinates(location_combinations)
    location_combinations.each do |combination|
      location_query = combination.join(", ")
      Rails.logger.info "Processing location_query #{location_query.inspect} ..."

      begin
        result = Geocoder.search(location_query, params: { countrycodes: "CM" }).first
        return result&.coordinates if result&.coordinates.present?
      rescue Geocoder::Error => e
        Rails.logger.error "Geocoder error: #{e.message}"
      end

      sleep(1)
    end
    nil
  end

  def create_or_update_entreprise(row)
    # Vérifiez si les coordonnées existent déjà dans la ligne CSV
    latitude = row["LATITUDE"].presence || row["latitude"].presence
    longitude = row["LONGITUDE"].presence || row["longitude"].presence

    # Si les coordonnées ne sont pas présentes dans le CSV, tentez de les récupérer
    unless latitude && longitude
      location_elements = [ row["QUARTIER"] || row["quartier"], row["COMMUNE"] || row["commune"], row["VILLE"] || row["ville"], row["DEPARTEMENT"] || row["departement"], row["REGION"] || row["region"] ].compact
      location_combinations = (1..location_elements.size).flat_map { |size| location_elements.combination(size).to_a }
      coordinates = fetch_coordinates(location_combinations)
      latitude, longitude = coordinates if coordinates
    end

    existing_record = Entreprise.find_by(niu: row["NIU"] || row["niu"])

    if existing_record
      # Si les coordonnées ne sont pas présentes, mettez à jour l'enregistrement existant
      if latitude.nil? && longitude.nil?
        existing_record.update(
          niu: row["NIU"] || row["niu"],
          forme: row["FORME"] || row["forme"],
          raison_sociale_rgpd: row["RAISON_SOCIALE_RGPD"] || row["raison_sociale_rgpd"],
          sigle: row["SIGLE"] || row["sigle"],
          activite: row["ACTIVITE"] || row["activite"],
          region: row["REGION"] || row["region"],
          departement: row["DEPARTEMENT"] || row["departement"],
          ville: row["VILLE"] || row["ville"],
          commune: row["COMMUNE"] || row["commune"],
          quartier: row["QUARTIER"] || row["quartier"],
          lieux_dit: row["LIEUX_DIT"] || row["lieux_dit"],
          boite_postale: row["BOITE_POSTALE"] || row["boite_postale"],
          npc: row["NPC"] || row["npc"],
          npc_intitule: row["NPC_INTITULE"] || row["npc_intitule"],
          isic_refined: row["ISIC_REFINED"] || row["isic_refined"],
          isic_1_dig: row["ISIC_1_DIG"] || row["isic_1_dig"],
          isic_2_dig: row["ISIC_2_DIG"] || row["isic_2_dig"],
          isic_3_dig: row["ISIC_3_DIG"] || row["isic_3_dig"],
          isic_4_dig: row["ISIC_4_DIG"] || row["isic_4_dig"],
          isic_intitule: row["ISIC_INTITULE"] || row["isic_intitule"],
          latitude:,
          longitude:,
          isic_1_dig_description: row["ISIC_1_DIG_DESCRIPTION"] || row["isic_1_dig_description"],
          isic_2_dig_description: row["ISIC_2_DIG_DESCRIPTION"] || row["isic_2_dig_description"],
          isic_3_dig_description: row["ISIC_3_DIG_DESCRIPTION"] || row["isic_3_dig_description"],
          isic_4_dig_description: row["ISIC_4_DIG_DESCRIPTION"] || row["isic_4_dig_description"],
          isic_refined_intitule: row["ISIC_REFINED_INTITULE"] || row["isic_refined_intitule"],
        )
      end
    else
      # Sinon, créez un nouvel enregistrement
      Entreprise.create(
        niu: row["NIU"] || row["niu"],
        forme: row["FORME"] || row["forme"],
        raison_sociale_rgpd: row["RAISON_SOCIALE_RGPD"] || row["raison_sociale_rgpd"],
        sigle: row["SIGLE"] || row["sigle"],
        activite: row["ACTIVITE"] || row["activite"],
        region: row["REGION"] || row["region"],
        departement: row["DEPARTEMENT"] || row["departement"],
        ville: row["VILLE"] || row["ville"],
        commune: row["COMMUNE"] || row["commune"],
        quartier: row["QUARTIER"] || row["quartier"],
        lieux_dit: row["LIEUX_DIT"] || row["lieux_dit"],
        boite_postale: row["BOITE_POSTALE"] || row["boite_postale"],
        npc: row["NPC"] || row["npc"],
        npc_intitule: row["NPC_INTITULE"] || row["npc_intitule"],
        isic_refined: row["ISIC_REFINED"] || row["isic_refined"],
        isic_1_dig: row["ISIC_1_DIG"] || row["isic_1_dig"],
        isic_2_dig: row["ISIC_2_DIG"] || row["isic_2_dig"],
        isic_3_dig: row["ISIC_3_DIG"] || row["isic_3_dig"],
        isic_4_dig: row["ISIC_4_DIG"] || row["isic_4_dig"],
        isic_intitule: row["ISIC_INTITULE"] || row["isic_intitule"],
        latitude:,
        longitude:,
        isic_1_dig_description: row["ISIC_1_DIG_DESCRIPTION"] || row["isic_1_dig_description"],
        isic_2_dig_description: row["ISIC_2_DIG_DESCRIPTION"] || row["isic_2_dig_description"],
        isic_3_dig_description: row["ISIC_3_DIG_DESCRIPTION"] || row["isic_3_dig_description"],
        isic_4_dig_description: row["ISIC_4_DIG_DESCRIPTION"] || row["isic_4_dig_description"],
        isic_refined_intitule: row["ISIC_REFINED_INTITULE"] || row["isic_refined_intitule"],
      )
    end
  end
end
