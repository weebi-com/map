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
        row = row.to_h.transform_keys(&:downcase)

        next if row["niu"].blank?

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
    latitude = row["latitude"].presence
    longitude = row["longitude"].presence

    # Si les coordonnées ne sont pas présentes dans le CSV, tentez de les récupérer
    unless latitude && longitude
      location_elements = [ row["quartier"], row["commune"], row["ville"], row["departement"], row["region"] ].compact
      location_combinations = (1..location_elements.size).flat_map { |size| location_elements.combination(size).to_a }
      coordinates = fetch_coordinates(location_combinations)
      latitude, longitude = coordinates if coordinates
    end

    existing_record = Entreprise.find_by(niu: row["niu"])

    if existing_record
      # Si les coordonnées ne sont pas présentes, mettez à jour l'enregistrement existant
      if latitude.nil? && longitude.nil?
        existing_record.update(
          niu: row["niu"],
          forme: row["forme"],
          raison_sociale_rgpd: row["raison_sociale_rgpd"],
          sigle: row["sigle"],
          activite: row["activite"],
          region: row["region"],
          departement: row["departement"],
          ville: row["ville"],
          commune: row["commune"],
          quartier: row["quartier"],
          lieux_dit: row["lieux_dit"],
          boite_postale: row["boite_postale"],
          npc: row["npc"],
          npc_intitule: row["npc_intitule"],
          isic_refined: row["isic_refined"],
          isic_1_dig: row["isic_1_dig"],
          isic_2_dig: row["isic_2_dig"],
          isic_3_dig: row["isic_3_dig"],
          isic_4_dig: row["isic_4_dig"],
          isic_intitule: row["isic_intitule"],
          latitude:,
          longitude:,
          isic_1_dig_description: row["isic_1_dig_description"],
          isic_2_dig_description: row["isic_2_dig_description"],
          isic_3_dig_description: row["isic_3_dig_description"],
          isic_4_dig_description: row["isic_4_dig_description"],
          isic_refined_intitule: row["isic_refined_intitule"],
        )
      end
    else
      # Sinon, créez un nouvel enregistrement
      Entreprise.create(
        niu: row["niu"],
        forme: row["forme"],
        raison_sociale_rgpd: row["raison_sociale_rgpd"],
        sigle: row["sigle"],
        activite: row["activite"],
        region: row["region"],
        departement: row["departement"],
        ville: row["ville"],
        commune: row["commune"],
        quartier: row["quartier"],
        lieux_dit: row["lieux_dit"],
        boite_postale: row["boite_postale"],
        npc: row["npc"],
        npc_intitule: row["npc_intitule"],
        isic_refined: row["isic_refined"],
        isic_1_dig: row["isic_1_dig"],
        isic_2_dig: row["isic_2_dig"],
        isic_3_dig: row["isic_3_dig"],
        isic_4_dig: row["isic_4_dig"],
        isic_intitule: row["isic_intitule"],
        latitude:,
        longitude:,
        isic_1_dig_description: row["isic_1_dig_description"],
        isic_2_dig_description: row["isic_2_dig_description"],
        isic_3_dig_description: row["isic_3_dig_description"],
        isic_4_dig_description: row["isic_4_dig_description"],
        isic_refined_intitule: row["isic_refined_intitule"],
      )
    end
  end
end
