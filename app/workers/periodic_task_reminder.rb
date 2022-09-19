require "sidekiq-scheduler"

class PeriodicTaskReminder
  include Sidekiq::Worker

  def perform
    Measure.tasks.with_pending_reminders.each do |measure|
      # TODO: Send periodic reminder
    end
  end
end
