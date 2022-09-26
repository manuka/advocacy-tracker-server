class UserMeasure < VersionedRecord
  belongs_to :user
  belongs_to :measure

  validates :user_id, uniqueness: {scope: :measure_id}
  validates :user_id, presence: true
  validates :measure_id, presence: true

  def notify?
    measure.notifications?
  end

  after_commit :set_relationship_updated, on: [:create, :update, :destroy]

  private

  def set_relationship_updated
    if measure && !measure.destroyed?
      measure.update_column(:relationship_updated_at, Time.zone.now)
      measure.update_column(:relationship_updated_by_id, ::PaperTrail.request.whodunnit)
    end

    if user && !user.destroyed?
      user.update_column(:relationship_updated_at, Time.zone.now)
      user.update_column(:relationship_updated_by_id, ::PaperTrail.request.whodunnit)
    end
  end
end
