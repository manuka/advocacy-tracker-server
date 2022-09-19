class CreateTaskNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :task_notifications do |t|
      t.belongs_to :measure, null: false, foreign_key: true

      t.timestamp :created_at, null: false
    end
  end
end
