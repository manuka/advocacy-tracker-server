class ActorMeasure < VersionedRecord
  belongs_to :actor, required: true
  belongs_to :measure, required: true

  validate :actor_actortype_is_active
  after_commit :set_relationship_updated_at, on: [:create, :update, :destroy]

  private

  def actor_actortype_is_active
    errors.add(:actor, "actor's actortype is not active") unless actor&.actortype&.is_active
  end

  def set_relationship_updated_at
    actor.update_column(:relationship_updated_at, Time.zone.now) if actor && !actor.destroyed?
    measure.update_column(:relationship_updated_at, Time.zone.now) if measure && !measure.destroyed?
  end
end
