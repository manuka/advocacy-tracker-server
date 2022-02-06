class MeasureCategory < VersionedRecord
  belongs_to :measure
  belongs_to :category
  accepts_nested_attributes_for :measure
  accepts_nested_attributes_for :category

  validates :category_id, uniqueness: {scope: :measure_id}
  validates :measure_id, presence: true
  validates :category_id, presence: true

  validate :category_taxonomy_enabled_for_measuretype

  private

  def category_taxonomy_enabled_for_measuretype
    unless category&.taxonomy&.measuretype_ids&.include?(measure&.measuretype_id)
      errors.add(:measure_id, "must have the category's taxonomy enabled for its measuretype")
    end
  end
end
