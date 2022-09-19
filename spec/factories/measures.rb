FactoryBot.define do
  factory :measure do
    title { Faker::Creature::Cat.registry }
    description { Faker::Beer.name }
    association(:measuretype)
    target_date { Faker::Date.forward(days: 450) }

    trait :draft do
      draft { true }
    end

    trait :published do
      draft { false }
    end

    trait :without_recommendation do
      recommendations { [] }
    end

    trait :without_category do
      categories { [] }
    end

    trait :is_archive do
      is_archive { true }
    end

    trait :not_is_archive do
      is_archive { false }
    end

    trait :not_private do
      private { false }
    end

    trait :private do
      private { true }
    end
  end
end
