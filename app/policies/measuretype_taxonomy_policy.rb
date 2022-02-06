# frozen_string_literal: true

class MeasuretypeTaxonomyPolicy < SystemPolicy
  def permitted_attributes
    [:measuretype_id, :taxonomy_id]
  end
end
