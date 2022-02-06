class AddPrivateToPages < ActiveRecord::Migration[6.1]
  def change
    change_table :pages do |t|
      t.boolean :private, default: true, index: true
    end
  end
end
