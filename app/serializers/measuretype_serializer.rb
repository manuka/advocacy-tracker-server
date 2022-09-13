class MeasuretypeSerializer
  include FastApplicationSerializer

  attributes(
    :has_parent,
    :has_target,
    :notifications,
    :title
  )

  set_type :measuretypes
end
