class MembershipSerializer
  include FastVersionedSerializer

  attributes :member_id, :memberof_id, :created_by_id

  set_type :memberships
end
