class CreateMeasureResources < ActiveRecord::Migration[6.1]
  def change
    create_table :measure_resources do |t|
      t.belongs_to :measure, null: false, foreign_key: true
      t.belongs_to :resource, null: false, foreign_key: true

      t.belongs_to :created_by, index: true, foreign_key: {to_table: "users"}
      t.timestamps
    end
  end
end
