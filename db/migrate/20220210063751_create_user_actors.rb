class CreateUserActors < ActiveRecord::Migration[6.1]
  def change
    create_table :user_actors, id: :serial do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :actor, null: false, foreign_key: true
      t.belongs_to :created_by, foreign_key: {to_table: :users}
      t.belongs_to :updated_by, foreign_key: {to_table: :users}

      t.timestamps
    end

    add_index :user_actors, [:user_id, :actor_id], unique: true
  end
end
