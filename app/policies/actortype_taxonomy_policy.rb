# frozen_string_literal: true

class ActortypeTaxonomyPolicy < SystemPolicy
  def permitted_attributes
    [:actortype_id, :taxonomy_id]
  end
end
