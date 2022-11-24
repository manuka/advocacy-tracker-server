FactoryBot.define do
  factory :role do
    name { Faker::Lorem.word }
    friendly_name { Faker::Lorem.sentence }

    trait :admin do
      name { "admin" }
    end

    trait :analyst do
      name { "analyst" }
    end

    trait :coordinator do
      name { "coordinator" }
    end

    trait :manager do
      name { "manager" }
    end
  end
end
