# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


User.find_or_create_by!(email: "boutique@boutique.com") do |user|
    # Set secure password (never store passwords in plain text)
    user.password = user.password_confirmation = "boutique@boutique.com"
    user.save!(validate: false)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Error creating user: #{e.message}"
  end