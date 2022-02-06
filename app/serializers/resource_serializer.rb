class ResourceSerializer
  include FastVersionedSerializer

  attributes :access_date,
    :description,
    :draft,
    :private,
    :publication_date,
    :status,
    :title,
    :resourcetype_id,
    :url

  set_type :resources
end
