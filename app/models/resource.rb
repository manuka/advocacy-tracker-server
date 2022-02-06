class Resource < VersionedRecord
  belongs_to :resourcetype, required: true

  validates :title, presence: true
  validates :resourcetype_id, presence: true
end
