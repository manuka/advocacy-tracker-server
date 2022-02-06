class CreateActorCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :actor_categories do |t|
      t.belongs_to :actor, foreign_key: true, index: true, null: false
      t.belongs_to :category, foreign_key: true, index: true, null: false

      t.belongs_to :created_by, foreign_key: {to_table: "users"}, index: true

      t.timestamps
    end
  end
end
