# frozen_string_literal: true

class MeasurePolicy < ApplicationPolicy
  def permitted_attributes
    [
      :amount_comment,
      :amount,
      :code,
      :comment,
      :date_comment,
      :date_end,
      :date_start,
      :description,
      :draft,
      :has_reference_landbased_ml,
      :indicator_summary,
      :measuretype_id,
      :outcome,
      :parent_id,
      :private,
      :reference_landbased_ml,
      :reference_ml,
      :status_comment,
      :status_lbs_protocol,
      :target_comment,
      :target_date_comment,
      :target_date,
      :title,
      :url,
      measure_categories_attributes: [
        :category_id,
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
      ],
      recommendation_measures_attributes: [
        :recommendation_id,
        recommendation_attributes: [
          :draft,
          :id,
          :number,
          :title
        ]
      ]
    ]
  end
end
