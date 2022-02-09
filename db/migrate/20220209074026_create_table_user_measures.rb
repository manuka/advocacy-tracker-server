class CreateTableUserMeasures < ActiveRecord::Migration[6.1]
  def change
    create_table :user_measures, id: :serial do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :measure, null: false, foreign_key: true
      t.belongs_to :created_by, null: false, foreign_key: {to_table: :users}
      t.belongs_to :updated_by, null: false, foreign_key: {to_table: :users}

      t.timestamps
    end

    add_index :user_measures, [:user_id, :measure_id], unique: true
  end
end
