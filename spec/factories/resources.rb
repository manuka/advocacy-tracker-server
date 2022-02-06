FactoryBot.define do
  factory :resource do
    access_date { Date.today }
    association(:resourcetype)
    description { Faker::Movies::StarWars.quote }
    draft { false }
    private { true }
    publication_date { Date.today }
    status { Faker::Creature::Cat.registry }
    title { "MyString" }
    url { "https://impactoss.org" }
  end
end
