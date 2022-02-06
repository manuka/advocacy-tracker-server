class CreateActors < ActiveRecord::Migration[6.1]
  def change
    create_table :actors do |t|
      t.belongs_to :actor_type, index: true, null: false, foreign_key: true
      t.string :code, null: false
      t.string :title, null: false
      t.text :description
      t.text :activity_summary
      t.string :url
      t.decimal :population
      t.decimal :gdp
      t.boolean :private, default: true
      t.boolean :draft, default: true

      t.timestamps
    end
  end
end
