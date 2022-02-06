class Actor < VersionedRecord
  belongs_to :actortype, required: true

  has_many :memberships, foreign_key: :memberof_id, dependent: :destroy
  has_many :members, class_name: "Actor", through: :memberships, source: :member

  has_many :membershipsof, class_name: "Membership", foreign_key: :member_id, dependent: :destroy
  has_many :membersof, class_name: "Actor", through: :membershipsof, source: :memberof

  has_many :actor_categories, dependent: :destroy
  has_many :categories, through: :actor_categories

  has_many :actor_measures, dependent: :destroy
  has_many :active_measures, through: :actor_measures

  has_many :measure_actors, dependent: :destroy
  has_many :passive_measures, through: :measure_actors

  validates :title, presence: true
end
