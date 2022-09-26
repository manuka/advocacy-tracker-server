class Membership < VersionedRecord
  belongs_to :member, class_name: "Actor", required: true
  belongs_to :memberof, class_name: "Actor", required: true

  belongs_to :created_by, class_name: "User", required: false

  validate :member_not_memberof

  after_commit :set_relationship_updated, on: [:create, :update, :destroy]

  private

  def member_not_memberof
    errors.add(:member, "can't be the same as memberof") if member == memberof
  end

  def set_relationship_updated
    if member && !member.destroyed?
      member.update_column(:relationship_updated_at, Time.zone.now)
      member.update_column(:relationship_updated_by_id, ::PaperTrail.request.whodunnit)
    end

    if memberof && !memberof.destroyed?
      memberof.update_column(:relationship_updated_at, Time.zone.now)
      memberof.update_column(:relationship_updated_by_id, ::PaperTrail.request.whodunnit)
    end
  end
end
