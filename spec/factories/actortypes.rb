FactoryBot.define do
  factory :actortype do
    title { Faker::Creature::Cat.registry }

    trait :with_members do
      has_members { true }
    end

    trait :active do
      is_active { true }
    end

    trait :target do
      is_target { true }
    end
  end
end
