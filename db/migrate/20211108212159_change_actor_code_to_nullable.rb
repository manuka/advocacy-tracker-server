class ChangeActorCodeToNullable < ActiveRecord::Migration[6.1]
  def up
    change_column :actors, :code, :string, null: true
  end

  def down
    change_column :actors, :code, :string, null: false
  end
end
