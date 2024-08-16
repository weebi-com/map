class Api::V1::EntreprisesController < ApplicationController
  def index
    entreprises = Entreprise.with_coordinates

    categories = Category.all
    colors = generate_category_colors(categories)

    render json: {
      entreprises:,
      categories:,
      colors:
    }
  end

  private

  def generate_category_colors(categories)
    predefined_colors = {}
    color_names = %w[red blue green yellow orange purple pink brown black white]
    extended_color_names = generate_extended_colors(color_names, categories.count)

    categories.each_with_index do |category, index|
      predefined_colors[category.description] = extended_color_names[index]
    end

    predefined_colors
  end

  def generate_extended_colors(color_names, count)
    extended_colors = color_names.dup
    extended_colors += color_names while extended_colors.size < count
    extended_colors.take(count)
  end
end
