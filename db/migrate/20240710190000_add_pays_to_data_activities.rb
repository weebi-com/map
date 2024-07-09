class AddPaysToDataActivities < ActiveRecord::Migration[7.1]
  def change
    add_column :data_activities, :pays, :string
  end
end
