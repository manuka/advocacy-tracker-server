class Membership < VersionedRecord
  belongs_to :member, class_name: "Actor", required: true
  belongs_to :memberof, class_name: "Actor", required: true

  belongs_to :created_by, class_name: "User", required: false

  validate :member_not_memberof

  private

  def member_not_memberof
    errors.add(:member, "can't be the same as memberof") if member == memberof
  end
end
