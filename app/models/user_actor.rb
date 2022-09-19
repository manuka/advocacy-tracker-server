class UserActor < VersionedRecord
  belongs_to :user
  belongs_to :actor

  validates :user_id, uniqueness: {scope: :actor_id}
  validates :user_id, presence: true
  validates :actor_id, presence: true

  after_commit :set_relationship_updated, on: [:create, :update, :destroy]

  private

  def set_relationship_updated
    if actor && !actor.destroyed?
      actor.update_column(:relationship_updated_at, Time.zone.now)
      actor.update_column(:relationship_updated_by_id, ::PaperTrail.request.whodunnit)
    end

    if user && !user.destroyed?
      user.update_column(:relationship_updated_at, Time.zone.now)
      user.update_column(:relationship_updated_by_id, ::PaperTrail.request.whodunnit)
    end
  end
end
