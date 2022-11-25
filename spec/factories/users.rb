# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    name { Faker::Name.name }
    password { "password" }
    password_confirmation { password }
  end

  trait :admin do
    roles { [create(:role, :admin)] }
  end

  trait :coordinator do
    roles { [create(:role, :coordinator)] }
  end

  trait :manager do
    roles { [create(:role, :manager)] }
  end

  trait :analyst do
    roles { [create(:role, :analyst)] }
  end
end
