class MeasureResourceSerializer
  include FastVersionedSerializer

  attributes :measure_id, :resource_id

  set_type :measure_resources
end
