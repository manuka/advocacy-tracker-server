class MeasureMeasureSerializer
  include FastVersionedSerializer

  attributes :measure_id, :other_measure_id

  set_type :measure_measures
end
