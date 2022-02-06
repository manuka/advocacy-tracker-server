FactoryBot.define do
  factory :actor do
    association(:actortype, :active, :target)
    activity_summary { Faker::Ancient.primordial }
    code { Faker::Beer.name }
    title { Faker::Creature::Cat.registry }
    description { Faker::Movies::StarWars.quote }

    trait :not_draft do
      draft { false }
    end

    trait :not_private do
      private { false }
    end
  end
end
