# frozen_string_literal: true

class ActorMeasurePolicy < ApplicationPolicy
  def permitted_attributes
    [
      :actor_id,
      :created_by_id,
      :date_end,
      :date_start,
      :measure_id,
      :updated_by_id,
      :value
    ]
  end
end
