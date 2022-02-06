class MeasuretypeTaxonomySerializer
  include FastApplicationSerializer

  attributes :measuretype_id, :taxonomy_id

  set_type :measuretype_taxonomies
end
