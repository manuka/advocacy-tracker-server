class DepluraliseFirstManyToManyTables < ActiveRecord::Migration[6.1]
  def change
    rename_table :actors_measures, :actor_measures
    rename_table :measures_actors, :measure_actors
    rename_table :actortypes_taxonomies, :actortype_taxonomies
    rename_table :measuretypes_taxonomies, :measuretype_taxonomies
  end
end
