class UserActor < VersionedRecord
  belongs_to :user
  belongs_to :actor

  validates :user_id, uniqueness: {scope: :actor_id}
  validates :user_id, presence: true
  validates :actor_id, presence: true
end
