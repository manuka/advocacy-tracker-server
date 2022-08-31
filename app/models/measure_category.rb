class MeasureCategory < VersionedRecord
  belongs_to :measure
  belongs_to :category
  accepts_nested_attributes_for :measure
  accepts_nested_attributes_for :category

  validates :category_id, uniqueness: {scope: :measure_id}
  validates :measure_id, presence: true
  validates :category_id, presence: true

  validate :category_taxonomy_enabled_for_measuretype

  after_commit :set_relationship_updated_at, on: [:create, :update, :destroy]

  private

  def category_taxonomy_enabled_for_measuretype
    unless category&.taxonomy&.measuretype_ids&.include?(measure&.measuretype_id)
      errors.add(:measure_id, "must have the category's taxonomy enabled for its measuretype")
    end
  end

  def set_relationship_updated_at
    measure.update_column(:relationship_updated_at, Time.zone.now) if measure && !measure.destroyed?
  end
end
