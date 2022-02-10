# frozen_string_literal: true

class MeasureMeasurePolicy < ApplicationPolicy
  def permitted_attributes
    [
      :created_by_id,
      :measure_id,
      :other_measure_id,
      :updated_by_id
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
