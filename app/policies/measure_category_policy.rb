# frozen_string_literal: true

class MeasureCategoryPolicy < ApplicationPolicy
  def permitted_attributes
    [
      :category_id,
      :measure_id,
      measure_attributes: [
        :description,
        :draft,
        :target_date,
        :title
      ],
      category_attributes: [
        :description,
        :draft,
        :id,
        :manager_id,
        :short_title,
        :taxonomy_id,
        :title,
        :url
      ]
    ]
  end

  def update?
    false
  end
end
