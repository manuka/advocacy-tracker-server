class UserMeasureSerializer
  include FastVersionedSerializer

  attributes :user_id, :measure_id

  set_type :user_measures
end
