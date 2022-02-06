# frozen_string_literal: true

class ActorCategoryPolicy < ApplicationPolicy
  def permitted_attributes
    [
      :category_id,
      :actor_id,
      actor_attributes: [
        :activity_summary,
        :actortype_id,
        :code,
        :description,
        :draft,
        :gdp,
        :population,
        :private,
        :title,
        :url
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
