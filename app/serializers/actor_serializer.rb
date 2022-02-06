class ActorSerializer
  include FastVersionedSerializer

  attributes(
    :activity_summary,
    :actortype_id,
    :code,
    :description,
    :draft,
    :gdp,
    :population,
    :private,
    :title,
    :url
  )

  set_type :actors
end
