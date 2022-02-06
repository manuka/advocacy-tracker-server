class MeasureResource < VersionedRecord
  belongs_to :measure, required: true
  belongs_to :resource, required: true

  accepts_nested_attributes_for :measure
  accepts_nested_attributes_for :resource

  validates :measure_id, presence: true
  validates :resource_id, presence: true, uniqueness: {scope: :measure_id}
end
