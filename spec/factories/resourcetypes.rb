FactoryBot.define do
  factory :resourcetype do
    title { Faker::Creature::Cat.registry }
  end
end
