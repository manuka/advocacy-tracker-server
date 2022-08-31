class UserActor < VersionedRecord
  belongs_to :user
  belongs_to :actor

  validates :user_id, uniqueness: {scope: :actor_id}
  validates :user_id, presence: true
  validates :actor_id, presence: true

  after_commit :set_relationship_updated_at, on: [:create, :update, :destroy]

  private

  def set_relationship_updated_at
    actor.update_column(:relationship_updated_at, Time.zone.now) if actor && !actor.destroyed?
    user.update_column(:relationship_updated_at, Time.zone.now) if user && !user.destroyed?
  end
end
