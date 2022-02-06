require "rails_helper"

RSpec.describe ActorMeasure, type: :model do
  it { is_expected.to belong_to :actor }
  it { is_expected.to belong_to :measure }

  it "will accept an actor whose actortype.is_active = true" do
    expect(
      described_class.new(
        actor: FactoryBot.build(:actor, actortype: FactoryBot.build(:actortype, :active)),
        measure: FactoryBot.build(:measure)
      )
    ).to be_valid
  end

  it "will reject an actor whose actortype.is_active = false" do
    actor_measure = described_class.new(
      actor: FactoryBot.build(:actor, actortype: FactoryBot.build(:actortype, is_active: false)),
      measure: FactoryBot.build(:measure)
    )
    expect(actor_measure).to be_invalid
    expect(actor_measure.errors[:actor]).to(include("actor's actortype is not active"))
  end
end
