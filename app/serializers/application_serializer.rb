class ApplicationSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :updated_at
  attribute :updated_by # , if: :current_user_has_permission?

  def created_at
    object.created_at&.in_time_zone&.iso8601
  end

  def updated_at
    object.updated_at&.in_time_zone&.iso8601
  end

  def current_user_has_permission?
    current_user && (current_user.role?("admin") || current_user.role?("manager"))
  end
end
