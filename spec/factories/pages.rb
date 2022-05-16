FactoryBot.define do
  factory :page do
    title { "MyString" }
    content { "MyText" }
    menu_title { "MyString" }
    draft { false }

    trait :not_private do
      private { false }
    end

    trait :private do
      private { true }
    end
  end
end
