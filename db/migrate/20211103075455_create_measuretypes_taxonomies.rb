class CreateMeasuretypesTaxonomies < ActiveRecord::Migration[6.1]
  def change
    create_table :measuretypes_taxonomies do |t|
      t.belongs_to :measuretype, foreign_key: true, index: true, null: false
      t.belongs_to :taxonomy, foreign_key: true, index: true, null: false

      t.timestamps
    end
  end
end
