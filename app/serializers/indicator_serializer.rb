class IndicatorSerializer
  include FastVersionedSerializer

  attributes(
    :title,
    :description,
    :reference,
    :draft,
    :manager_id,
    :frequency_months,
    :start_date,
    :repeat,
    :end_date,
    :private
  )

  set_type :indicators
end
