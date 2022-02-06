class CreateMeasuresActors < ActiveRecord::Migration[6.1]
  def change
    create_table :measures_actors do |t|
      t.belongs_to :actor, foreign_key: true, index: true, null: false
      t.belongs_to :measure, foreign_key: true, index: true, null: false
      t.date :date_start
      t.date :date_end
      t.decimal :value

      t.belongs_to :created_by, foreign_key: {to_table: "users"}, index: true, null: false
      t.belongs_to :updated_by, foreign_key: {to_table: "users"}, index: true, null: false

      t.timestamps
    end
  end
end
