# frozen_string_literal: true

class MeasureResourcePolicy < ApplicationPolicy
  def permitted_attributes
    [
      :measure_id,
      :resource_id
    ]
  end

  def update?
    false
  end
end
