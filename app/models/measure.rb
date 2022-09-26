# frozen_string_literal: true

class Measure < VersionedRecord
  has_many :recommendation_measures, inverse_of: :measure, dependent: :destroy
  has_many :measure_categories, inverse_of: :measure, dependent: :destroy
  has_many :measure_indicators, inverse_of: :measure, dependent: :destroy

  has_many :actor_measures, dependent: :destroy
  has_many :active_measures, through: :actor_measures

  has_many :measure_actors, dependent: :destroy
  has_many :passive_measures, through: :measure_actors

  has_many :measure_measures, dependent: :destroy
  has_many :measures, through: :measure_measures
  has_many :other_measure_measures, class_name: "MeasureMeasure", dependent: :destroy, foreign_key: :other_measure_id

  has_many :measure_resources, dependent: :destroy
  has_many :resources, through: :measure_resources

  has_many :recommendations, through: :recommendation_measures, inverse_of: :measures
  has_many :categories, through: :measure_categories, inverse_of: :measures
  has_many :indicators, through: :measure_indicators, inverse_of: :measures
  has_many :due_dates, through: :indicators
  has_many :progress_reports, through: :indicators

  has_many :user_measures, dependent: :destroy
  has_many :users, through: :user_measures

  belongs_to :measuretype, required: true
  belongs_to :parent, class_name: "Measure", required: false

  belongs_to :relationship_updated_by, class_name: "User", required: false

  accepts_nested_attributes_for :recommendation_measures
  accepts_nested_attributes_for :measure_categories

  validates :title, presence: true
  validates :measuretype_id, presence: true
  validate(
    :different_parent,
    :not_own_descendant,
    :parent_id_allowed_by_measuretype
  )

  def self.notifiable_attribute_names
    Measure.attribute_names - %w[created_at draft is_archive updated_at]
  end

  def notifiable_user_measures(user_id:)
    user_measures.reject { |um| um.user.id == user_id }
  end

  after_commit :queue_task_updated_notifications!,
    on: :update,
    if: [:task?, :relationship_updated?]

  def queue_task_updated_notifications!(user_id: ::PaperTrail.request.whodunnit)
    return unless notify?

    delete_existing_task_notifications!(user_id:)

    notifiable_user_measures(user_id:).each do |user_measure|
      TaskNotificationJob.perform_in(ENV.fetch("TASK_NOTIFICATION_DELAY", 20).to_i.seconds, user_measure.id)
    end
  end

  private

  def delete_existing_task_notifications!(user_id:)
    user_measure_ids = notifiable_user_measures(user_id:).pluck(:id)

    Sidekiq::ScheduledSet.new
      .select { |job| user_measure_ids.include?(job.args.first) && job.klass == "TaskNotificationJob" }
      .map(&:delete)
  end

  def different_parent
    if parent_id && parent_id == id
      errors.add(:parent_id, "can't be the same as id")
    end
  end

  def notify?
    task? &&
      !is_archive? &&
      notifications? &&
      (!draft? && !saved_change_to_attribute?(:draft)) &&
      (saved_changes.keys & Measure.notifiable_attribute_names).any?
  end

  def not_own_descendant
    measure_parent = self
    while (measure_parent = measure_parent.parent)
      errors.add(:parent_id, "can't be its own descendant") if measure_parent.id == id
    end
  end

  def parent_id_allowed_by_measuretype
    if parent_id && !parent.measuretype&.has_parent
      errors.add(:parent_id, "is not allowed for this measuretype")
    end
  end

  def relationship_updated?
    saved_change_to_attribute?(:relationship_updated_at)
  end

  def task?
    measuretype&.notifications?
  end
end
