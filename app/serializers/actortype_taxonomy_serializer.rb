class ActortypeTaxonomySerializer
  include FastApplicationSerializer

  attributes :actortype_id, :taxonomy_id

  set_type :actortype_taxonomies
end
