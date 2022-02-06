FactoryBot.define do
  factory :measuretype_taxonomy do
    association :measuretype
    association :taxonomy
  end
end
