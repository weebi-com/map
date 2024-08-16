class CreateImportFiles < ActiveRecord::Migration[7.2]
  def change
    create_table :import_files do |t|
      t.string :status

      t.timestamps
    end
  end
end
