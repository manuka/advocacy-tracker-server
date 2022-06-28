class AddSupportlevelIdToMeasureIndicators < ActiveRecord::Migration[6.1]
  def change
    add_column :measure_indicators, :supportlevel_id, :bigint
  end
end
