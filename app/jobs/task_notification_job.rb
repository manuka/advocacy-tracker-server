class TaskNotificationJob
  include Sidekiq::Worker

  def perform(user_measure_id)
    user_measure = UserMeasure.find(user_measure_id)
    return unless user_measure&.notify?

    UserMeasureMailer.task_updated(user_measure).deliver_now
  end
end
