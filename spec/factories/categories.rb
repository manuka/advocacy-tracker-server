FactoryBot.define do
  factory :category do
    title { Faker::Ancient.hero }
    short_title { Faker::Ancient.primordial }
    description { Faker::Movies::StarWars.quote }
    url { Faker::Internet.url }
    association :taxonomy

    trait :parent_category do
      title { "parent" }
    end

    trait :sub_category do
      title { "sub" }
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
