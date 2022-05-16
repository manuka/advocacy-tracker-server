class AddPrivateToIndicators < ActiveRecord::Migration[6.1]
  def change
    add_column :indicators, :private, :boolean, default: false
  end
end
