class AddNewFieldsToActors < ActiveRecord::Migration[6.1]
  def change
    add_column :actors, :prefix, :string
    add_column :actors, :email, :string
    add_column :actors, :phone, :string
    add_column :actors, :address, :text
    add_reference :actors, :manager, foreign_key: {to_table: "users"}, index: true
    add_reference :actors, :parent, foreign_key: {to_table: "actors"}, index: true
  end
end
