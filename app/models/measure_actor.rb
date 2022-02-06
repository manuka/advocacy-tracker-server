class MeasureActor < VersionedRecord
  belongs_to :actor, required: true
  belongs_to :measure, required: true

  validate :actor_actortype_is_target, :measure_measuretype_has_target

  private

  def actor_actortype_is_target
    errors.add(:actor, "actor's actortype is not target") unless actor&.actortype&.is_target
  end

  def measure_measuretype_has_target
    errors.add(:measure, "measure's measuretype can't have target") unless measure&.measuretype&.has_target
  end
end
