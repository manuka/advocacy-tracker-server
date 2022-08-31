class Membership < VersionedRecord
  belongs_to :member, class_name: "Actor", required: true
  belongs_to :memberof, class_name: "Actor", required: true

  belongs_to :created_by, class_name: "User", required: false

  validate :member_not_memberof

  after_commit :set_relationship_updated_at, on: [:create, :update, :destroy]

  private

  def member_not_memberof
    errors.add(:member, "can't be the same as memberof") if member == memberof
  end

  def set_relationship_updated_at
    member.update_column(:relationship_updated_at, Time.zone.now) if member && !member.destroyed?
    memberof.update_column(:relationship_updated_at, Time.zone.now) if memberof && !memberof.destroyed?
  end
end
