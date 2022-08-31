class UserMeasure < VersionedRecord
  belongs_to :user
  belongs_to :measure

  validates :user_id, uniqueness: {scope: :measure_id}
  validates :user_id, presence: true
  validates :measure_id, presence: true

  after_commit :set_relationship_updated_at, on: [:create, :update, :destroy]

  private

  def set_relationship_updated_at
    measure.update_column(:relationship_updated_at, Time.zone.now) if measure && !measure.destroyed?
    user.update_column(:relationship_updated_at, Time.zone.now) if user && !user.destroyed?
  end
end
