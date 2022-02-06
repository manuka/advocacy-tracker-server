class CreateResources < ActiveRecord::Migration[6.1]
  def change
    create_table :resources do |t|
      t.string :title, null: false
      t.text :description
      t.text :url
      t.belongs_to :resourcetype, null: false, foreign_key: true
      t.boolean :private, default: true
      t.boolean :draft, default: true
      t.datetime :publication_date
      t.datetime :access_date
      t.text :status

      t.belongs_to :created_by, index: true
      t.belongs_to :updated_by, index: true
      t.timestamps
    end

    change_table :actor_measures do |t|
      t.belongs_to :resource, null: true, foreign_key: true
    end
  end
end
