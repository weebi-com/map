# app/controllers/imports_controller.rb
class ImportsController < ApplicationController
  before_action :authenticate_user!

  def new
    @import_file = ImportFile.new
  end

  def create
    @import_file = ImportFile.new
    handle_file_upload(@import_file, ImportEntrepriseDataJob)
  end

  def categories
    @import_file = ImportFile.new
    handle_file_upload(@import_file, ImportCategorieDataJob)
  end

  private

  def handle_file_upload(import_file, job)
    import_file.file.attach(import_params[:file])
    import_file.status = 'pending'

    if import_file.save
      job.perform_later(import_file.id)
      redirect_to root_path, notice: 'File uploaded. Processing in the background.'
    else
      render :new
    end
  end

  def import_params
    params.require(:import_file).permit(:file)
  end
end
