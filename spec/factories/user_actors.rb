FactoryBot.define do
  factory :user_actor do
    association :user
    association :actor

    association :created_by, factory: :user
    association :updated_by, factory: :user
  end
end
