FactoryBot.define do
  factory :measure_measure do
    association :measure
    association :other_measure, factory: :measure

    association :created_by, factory: :user
    association :updated_by, factory: :user
  end
end
