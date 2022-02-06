class Membership < VersionedRecord
  belongs_to :member, class_name: "Actor", required: true
  belongs_to :memberof, class_name: "Actor", required: true

  belongs_to :created_by, class_name: "User", required: false

  validate :member_not_memberof
  validate :memberof_actortype_has_members
  validate :member_has_no_members_itself

  private

  def member_not_memberof
    errors.add(:member, "can't be the same as memberof") if member == memberof
  end

  def memberof_actortype_has_members
    errors.add(:memberof, "actortype can't have members") unless memberof&.actortype&.has_members
  end

  def member_has_no_members_itself
    errors.add(:member, "can't also have members") if member&.actortype&.has_members
  end
end
