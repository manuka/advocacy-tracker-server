FactoryBot.define do
  factory :actor_category do
    association :actor
    association :category

    association :created_by, factory: :user
  end
end
