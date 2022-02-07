FactoryBot.define do
  factory :actor do
    association(:actortype, :active, :target)
    activity_summary { Faker::Ancient.primordial }
    code { Faker::Beer.name }
    address { Faker::Address.full_address }
    description { Faker::Movies::StarWars.quote }
    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.phone_number }
    prefix { Faker::Name.prefix }
    title { Faker::Creature::Cat.registry }

    trait :not_draft do
      draft { false }
    end

    trait :not_private do
      private { false }
    end
  end
end
