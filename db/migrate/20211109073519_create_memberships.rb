class CreateMemberships < ActiveRecord::Migration[6.1]
  def change
    create_table :memberships do |t|
      t.belongs_to :member, foreign_key: {to_table: "actors"}, index: true, null: false
      t.belongs_to :memberof, foreign_key: {to_table: "actors"}, index: true, null: false

      t.belongs_to :created_by, foreign_key: {to_table: "users"}, index: true

      t.timestamps
    end
  end
end
