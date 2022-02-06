class FixNaming < ActiveRecord::Migration[6.1]
  def change
    rename_table :actor_types, :actortypes
    rename_table :measure_types, :measuretypes

    rename_column :actors, :actor_type_id, :actortype_id
    rename_column :measures, :measure_type_id, :measuretype_id
  end
end
