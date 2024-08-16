require 'csv'
require 'open-uri'

class ImportCategorieDataJob < ApplicationJob
  queue_as :default

  def perform(import_file_id)
    Rails.logger.info 'Processing the perform action ...'

    import_file = ImportFile.find(import_file_id)
    Rails.logger.info "Processing import_file #{import_file.inspect} ..."

    import_file.update(status: 'processing')

    Rails.logger.info "Processing import_file #{import_file.inspect} ..."

    begin
      Rails.logger.info 'Begin ...'

      file_content = import_file.file.download

      csv_data = CSV.parse(file_content, headers: true)

      csv_data.each do |row|
        Rails.logger.info "Processing CSV #{row.inspect}"

        next if row['Code'].blank?

        Rails.logger.info "Processing #{row['Code']} #{row['Description']}"

        existing_record = Category.find_by(
          code: row['CODE'],
          description: row['DESCRIPTION']
        )

        next if existing_record

        Category.create!(
          code: row['Code'],
          description: row['Description']
        )
      end

      import_file.update(status: 'completed')
      Rails.logger.info 'End ...'
    rescue CSV::MalformedCSVError => e
      import_file.update(status: 'failed')
      Rails.logger.error "Failed to import file: #{e.message}"
    rescue StandardError => e
      import_file.update(status: 'failed')
      Rails.logger.error "Failed to import file: #{e.message}"
    end
  end
end
