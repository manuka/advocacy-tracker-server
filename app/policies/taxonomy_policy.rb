# frozen_string_literal: true

class TaxonomyPolicy < SystemPolicy
  def permitted_attributes
    [
      :allow_multiple,
      :framework_id,
      :groups_measures_default,
      :groups_recommendations_default,
      :has_date,
      :is_smart,
      :parent_id,
      :priority,
      :tags_measures,
      :tags_users,
      :title
    ]
  end
end
