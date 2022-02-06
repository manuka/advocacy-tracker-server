require "rails_helper"

RSpec.describe ActorCategory, type: :model do
  it { is_expected.to belong_to :actor }
  it { is_expected.to belong_to :category }
  it { is_expected.to validate_presence_of :category_id }
  it { is_expected.to validate_presence_of :actor_id }

  let(:actor) { FactoryBot.create(:actor) }
  let(:category) { FactoryBot.create(:category) }

  it "errors when the category's taxonomy is not enabled for its actortype" do
    actor_category = described_class.create(category: category, actor: actor)
    expect(actor_category).to be_invalid
    expect(actor_category.errors[:category]).to include("must have its taxonomy enabled for actor's actortype")
  end

  it "works when the category's taxonomy is enabled for its actortype" do
    FactoryBot.create(:actortype_taxonomy, actortype: actor.actortype, taxonomy: category.taxonomy)

    actor_category = described_class.create(category: category, actor: actor)
    expect(actor_category).to be_valid
  end
end
