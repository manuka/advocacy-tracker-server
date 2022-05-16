class ActorSerializer
  include FastVersionedSerializer

  attributes(
    :activity_summary,
    :actortype_id,
    :address,
    :code,
    :description,
    :draft,
    :email,
    :gdp,
    :manager_id,
    :parent_id,
    :phone,
    :population,
    :prefix,
    :private,
    :title,
    :url,
    :is_archive
  )

  set_type :actors
end
