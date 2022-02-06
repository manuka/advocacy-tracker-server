class MeasuretypeSerializer
  include FastApplicationSerializer

  attributes(
    :has_parent,
    :has_target,
    :title
  )

  set_type :measuretypes
end
