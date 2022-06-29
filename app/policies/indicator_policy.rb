# frozen_string_literal: true

class IndicatorPolicy < ApplicationPolicy
  def permitted_attributes
    [
      :code,
      :title,
      :description,
      :draft,
      :manager_id,
      :frequency_months,
      :start_date,
      :repeat,
      :end_date,
      :reference,
      :private,
      (:is_archive if @user.role?("admin")),
      measure_indicators_attributes: [
        :measure_id,
        measure_attributes: [:id, :title, :description, :target_date, :draft]
      ]
    ].compact
  end
end
