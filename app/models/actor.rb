class Actor < VersionedRecord
  belongs_to :actortype, required: true
  belongs_to :manager, class_name: "User", required: false
  belongs_to :parent, class_name: "Actor", required: false

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

  has_many :user_actors, dependent: :destroy
  has_many :users, through: :user_actors

  validates :title, presence: true
  validate :different_parent, :not_own_descendant

  private

  def different_parent
    if parent_id && parent_id == id
      errors.add(:parent_id, "can't be the same as id")
    end
  end

  def not_own_descendant
    measure_parent = self
    while (measure_parent = measure_parent.parent)
      errors.add(:parent_id, "can't be its own descendant") if measure_parent.id == id
    end
  end
end
