class IndicatorSerializer
  include FastVersionedSerializer

  attributes(
    :code,
    :title,
    :description,
    :reference,
    :draft,
    :manager_id,
    :frequency_months,
    :start_date,
    :repeat,
    :end_date,
    :private,
    :is_archive,
    :relationship_updated_at
  )

  set_type :indicators
end
