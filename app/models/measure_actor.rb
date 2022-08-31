class MeasureActor < VersionedRecord
  belongs_to :actor, required: true
  belongs_to :measure, required: true

  validate :actor_actortype_is_target, :measure_measuretype_has_target

  after_commit :set_relationship_updated_at, on: [:create, :update, :destroy]

  private

  def actor_actortype_is_target
    errors.add(:actor, "actor's actortype is not target") unless actor&.actortype&.is_target
  end

  def measure_measuretype_has_target
    errors.add(:measure, "measure's measuretype can't have target") unless measure&.measuretype&.has_target
  end

  def set_relationship_updated_at
    actor.update_column(:relationship_updated_at, Time.zone.now) if actor && !actor.destroyed?
    measure.update_column(:relationship_updated_at, Time.zone.now) if measure && !measure.destroyed?
  end
end
