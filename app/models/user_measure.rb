class UserMeasure < VersionedRecord
  belongs_to :user
  belongs_to :measure

  validates :user_id, uniqueness: {scope: :measure_id}
  validates :user_id, presence: true
  validates :measure_id, presence: true

  def notify?
    measure.notifications? && !(measure.draft? || measure.is_archive?)
  end
end
