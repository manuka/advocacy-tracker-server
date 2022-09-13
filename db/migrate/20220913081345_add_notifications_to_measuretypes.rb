class AddNotificationsToMeasuretypes < ActiveRecord::Migration[6.1]
  def change
    add_column :measuretypes, :notifications, :boolean, default: false
  end
end
