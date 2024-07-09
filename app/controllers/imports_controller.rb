# app/controllers/imports_controller.rb
class ImportsController < ApplicationController
  before_action :authenticate_user!

  def new
    @import_file = ImportFile.new
  end

  def create
    country_code = params[:import_file][:country]
    country = ISO3166::Country[country_code]
    country_name = country.translations['fr']

    @import_file = ImportFile.new
    @import_file.file.attach(import_params[:file])
    @import_file.country = country_name
    @import_file.status = 'pending'

    if @import_file.save
      ImportDataActivityDataJob.perform_later(@import_file.id, @import_file.country)
      redirect_to root_path, notice: 'File uploaded. Processing in the background.'
    else
      render :new
    end
  end

  private

  def import_params
    params.require(:import_file).permit(:file, :country)
  end
end
