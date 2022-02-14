class UserActorSerializer
  include FastVersionedSerializer

  attributes :user_id, :actor_id

  set_type :user_actors
end
