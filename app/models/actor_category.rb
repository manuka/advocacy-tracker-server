class ActorCategory < VersionedRecord
  belongs_to :actor, required: true
  belongs_to :category, required: true

  accepts_nested_attributes_for :actor
  accepts_nested_attributes_for :category

  validates :actor_id, presence: true
  validates :category_id, presence: true, uniqueness: {scope: :actor_id}
  validate :category_taxonomy_enabled_for_actortype

  private

  def category_taxonomy_enabled_for_actortype
    unless category&.taxonomy&.actortype_ids&.include?(actor&.actortype_id)
      errors.add(:category, "must have its taxonomy enabled for actor's actortype")
    end
  end
end
