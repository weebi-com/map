class AddPaysToImportFiles < ActiveRecord::Migration[7.1]
  def change
    add_column :import_files, :country, :string
  end
end
