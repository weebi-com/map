class Api::V1::EntreprisesController < ApplicationController
  def index
    codes = [14, 46, 47, 56]

    entreprises = Entreprise
      .where("CHAR_LENGTH(isic_2_dig::text) = ?", 2)
      .where.not(latitude: nil, longitude: nil)
      .where(isic_2_dig: codes)

    categories = Entreprise
      .select("isic_2_dig, isic_2_dig_description")
      .where("CHAR_LENGTH(isic_2_dig::text) = ?", 2)
      .where.not(latitude: nil, longitude: nil)
      .where(isic_2_dig: codes)
      .group("isic_2_dig, isic_2_dig_description")
      
    colors = generate_category_colors(categories)

    render json: {
      entreprises: entreprises,
      categories: categories,
      colors: colors
    }
  end

  private

  def generate_category_colors(categories)
    predefined_colors = {}
    color_names = %w[red blue green yellow orange purple pink brown black white]
    count = categories.length

    extended_color_names = generate_extended_colors(color_names, count)

    categories.each_with_index do |category, index|
      predefined_colors[category.isic_2_dig_description] = extended_color_names[index]
    end

    predefined_colors
  end

  def generate_extended_colors(color_names, count)
    extended_colors = color_names.dup
    extended_colors += color_names while extended_colors.size < count
    extended_colors.take(count)
  end
end
