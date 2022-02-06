class AddPrivateToCategories < ActiveRecord::Migration[6.1]
  def change
    add_column :categories, :private, :boolean, default: true
  end
end
