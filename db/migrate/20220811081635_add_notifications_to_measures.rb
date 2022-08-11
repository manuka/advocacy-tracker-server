class AddNotificationsToMeasures < ActiveRecord::Migration[6.1]
  def change
    add_column :measures, :notifications, :boolean, default: true
  end
end
