require "sidekiq-scheduler"

class TaskNotification
  include Sidekiq::Worker

  def perform
    Measure.tasks.with_pending_notifications.each do |measure|
      # TODO: notify
    end
  end
end
