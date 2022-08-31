class MeasureMeasure < VersionedRecord
  belongs_to :measure
  belongs_to :other_measure, class_name: "Measure"

  validates :measure_id, uniqueness: {scope: :other_measure_id}
  validates :measure_id, presence: true
  validates :other_measure_id, presence: true

  validate :measure_not_other_measure

  after_commit :set_relationship_updated_at, on: [:create, :update, :destroy]

  private

  def measure_not_other_measure
    errors.add(:measure, "can't be the same as other_measure") if measure == other_measure
  end

  def set_relationship_updated_at
    measure.update_column(:relationship_updated_at, Time.zone.now) if measure && !measure.destroyed?
    other_measure.update_column(:relationship_updated_at, Time.zone.now) if other_measure && !other_measure.destroyed?
  end
end
