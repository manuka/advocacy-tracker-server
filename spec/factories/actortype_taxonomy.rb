FactoryBot.define do
  factory :actortype_taxonomy do
    association :actortype
    association :taxonomy
  end
end
