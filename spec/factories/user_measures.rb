FactoryBot.define do
  factory :user_measure do
    association :user
    association :measure

    association :created_by, factory: :user
    association :updated_by, factory: :user
  end
end
