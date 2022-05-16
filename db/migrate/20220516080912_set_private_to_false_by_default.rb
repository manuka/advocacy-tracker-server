class SetPrivateToFalseByDefault < ActiveRecord::Migration[6.1]
  TABLES = %i[actors categories measures pages resources]

  def up
    TABLES.each do |table|
      change_column table, :private, :boolean, default: false
    end
  end

  def down
    TABLES.each do |table|
      change_column table, :private, :boolean, default: true
    end
  end
end
