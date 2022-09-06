class UserSerializer
  include FastVersionedSerializer

  attributes :email, :name, :relationship_updated_at

  set_type :users
end
