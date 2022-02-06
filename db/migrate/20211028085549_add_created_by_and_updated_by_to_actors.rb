class AddCreatedByAndUpdatedByToActors < ActiveRecord::Migration[6.1]
  def change
    change_table :actors do |t|
      t.belongs_to :created_by, index: true
      t.belongs_to :updated_by, index: true
    end
  end
end
