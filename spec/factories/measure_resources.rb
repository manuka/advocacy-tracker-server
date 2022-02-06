FactoryBot.define do
  factory :measure_resource do
    association :measure
    association :resource

    association :created_by, factory: :user
  end
end
