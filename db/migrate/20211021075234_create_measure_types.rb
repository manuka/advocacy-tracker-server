class CreateMeasureTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :measure_types do |t|
      t.string :title, null: false
      t.boolean :has_target, default: true
      t.boolean :has_parent, default: true

      t.timestamps
    end
  end
end
