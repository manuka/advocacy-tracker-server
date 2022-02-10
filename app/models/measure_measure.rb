class MeasureMeasure < VersionedRecord
  belongs_to :measure
  belongs_to :other_measure, class_name: "Measure"

  validates :measure_id, uniqueness: {scope: :other_measure_id}
  validates :measure_id, presence: true
  validates :other_measure_id, presence: true
end
