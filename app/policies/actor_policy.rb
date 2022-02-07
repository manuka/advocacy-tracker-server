# frozen_string_literal: true

class ActorPolicy < ApplicationPolicy
  def permitted_attributes
    [
      :activity_summary,
      :actortype_id,
      :address,
      :code,
      :description,
      :draft,
      :email,
      :gdp,
      :manager_id,
      :parent_id,
      :phone,
      :population,
      :prefix,
      :private,
      :title,
      :url
    ]
  end
end
