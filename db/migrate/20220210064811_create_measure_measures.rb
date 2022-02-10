class CreateMeasureMeasures < ActiveRecord::Migration[6.1]
  def change
    create_table :measure_measures do |t|
      t.belongs_to :measure, null: false, foreign_key: true
      t.belongs_to :other_measure, null: false, foreign_key: {to_table: :measures}
      t.belongs_to :created_by, foreign_key: {to_table: :users}
      t.belongs_to :updated_by, foreign_key: {to_table: :users}

      t.timestamps
    end

    add_index :measure_measures, [:measure_id, :other_measure_id], unique: true
  end
end
