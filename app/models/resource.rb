class Resource < VersionedRecord
  belongs_to :resourcetype, required: true

  validates :title, presence: true
  validates :resourcetype_id, presence: true

  has_many :measure_resources, dependent: :destroy
  has_many :measures, through: :measure_resources
end
