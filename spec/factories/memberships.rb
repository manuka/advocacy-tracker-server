FactoryBot.define do
  factory :membership do
    association :member, factory: :actor
    association :memberof, factory: :actor
  end
end
