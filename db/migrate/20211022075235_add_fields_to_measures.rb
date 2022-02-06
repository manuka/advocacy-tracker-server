class AddFieldsToMeasures < ActiveRecord::Migration[6.1]
  def change
    change_table(:measures) do |t|
      t.belongs_to :measure_type, foreign_key: true
      t.belongs_to :parent, foreign_key: {to_table: :measures}
      t.string :code
      t.string :comment
      t.string :url
      t.datetime :date_start
      t.datetime :date_end
      t.string :date_comment
      t.string :target_comment
      t.string :status_comment
      t.string :reference_ml
      t.string :reference_landbased_ml
      t.boolean :has_reference_landbased_ml
      t.string :status_lbs_protocol
      t.decimal :amount
      t.string :amount_comment
      t.boolean :private, default: true
    end
  end
end
