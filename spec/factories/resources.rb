FactoryBot.define do
  factory :resource do
    access_date { Date.today }
    association(:resourcetype)
    description { Faker::Movies::StarWars.quote }
    draft { false }
    publication_date { Date.today }
    status { Faker::Creature::Cat.registry }
    title { "MyString" }
    url { "https://impactoss.org" }

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
