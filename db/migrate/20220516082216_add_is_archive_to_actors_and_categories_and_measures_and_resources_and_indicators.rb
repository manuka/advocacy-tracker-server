class AddIsArchiveToActorsAndCategoriesAndMeasuresAndResourcesAndIndicators < ActiveRecord::Migration[6.1]
  def change
    add_column :actors, :is_archive, :boolean, default: false
    add_column :categories, :is_archive, :boolean, default: false
    add_column :measures, :is_archive, :boolean, default: false
    add_column :resources, :is_archive, :boolean, default: false
    add_column :indicators, :is_archive, :boolean, default: false
  end
end
