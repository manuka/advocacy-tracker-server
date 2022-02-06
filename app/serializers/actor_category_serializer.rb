class ActorCategorySerializer
  include FastVersionedSerializer

  attributes :actor_id, :category_id

  set_type :actor_categories
end
