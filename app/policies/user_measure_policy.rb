# frozen_string_literal: true

class UserMeasurePolicy < ApplicationPolicy
  def permitted_attributes
    [
      :created_by_id,
      :measure_id,
      :updated_by_id,
      :user_id
    ]
  end

  def update?
    false
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
