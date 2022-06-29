class AddCodeToIndicators < ActiveRecord::Migration[6.1]
  def change
    add_column :indicators, :code, :string
  end
end
