class CreateActorTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :actor_types do |t|
      t.string :title, null: false
      t.boolean :has_members, default: false
      t.boolean :is_active, default: false
      t.boolean :is_target, default: false

      t.timestamps
    end
  end
end
