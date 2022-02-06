class RemoveNullConstraintsFromCreatedByIdAndUpdatedById < ActiveRecord::Migration[6.1]
  def up
    change_column :actor_measures, :created_by_id, :bigint, null: true
    change_column :measure_actors, :created_by_id, :bigint, null: true
    change_column :actor_measures, :updated_by_id, :bigint, null: true
    change_column :measure_actors, :updated_by_id, :bigint, null: true
  end

  def down
    change_column :actor_measures, :created_by_id, :bigint, null: false
    change_column :measure_actors, :created_by_id, :bigint, null: false
    change_column :actor_measures, :updated_by_id, :bigint, null: false
    change_column :measure_actors, :updated_by_id, :bigint, null: false
  end
end
