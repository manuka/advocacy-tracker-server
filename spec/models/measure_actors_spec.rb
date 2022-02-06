require "rails_helper"

RSpec.describe MeasureActor, type: :model do
  it { is_expected.to belong_to :actor }
  it { is_expected.to belong_to :measure }

  it "will accept an actor whose actortype.is_target = true" do
    expect(
      described_class.new(
        actor: FactoryBot.build(:actor, actortype: FactoryBot.build(:actortype, :target)),
        measure: FactoryBot.build(:measure)
      )
    ).to be_valid
  end

  it "will reject an actor whose actortype.is_target = false" do
    measure_actor = described_class.new(
      actor: FactoryBot.build(:actor, actortype: FactoryBot.build(:actortype, is_target: false)),
      measure: FactoryBot.build(:measure)
    )
    expect(measure_actor).to be_invalid
    expect(measure_actor.errors[:actor]).to(include("actor's actortype is not target"))
  end

  it "will accept a measure whose measuretype.has_target = true" do
    expect(
      described_class.new(
        actor: FactoryBot.build(:actor, actortype: FactoryBot.build(:actortype, :target)),
        measure: FactoryBot.build(:measure, measuretype: FactoryBot.build(:measuretype, has_target: true))
      )
    ).to be_valid
  end

  it "will reject a measure whose measuretype.has_target = false" do
    measure_actor = described_class.new(
      actor: FactoryBot.build(:actor, actortype: FactoryBot.build(:actortype, :target)),
      measure: FactoryBot.build(:measure, measuretype: FactoryBot.build(:measuretype, has_target: false))
    )
    expect(measure_actor).to be_invalid
    expect(measure_actor.errors[:measure]).to(include("measure's measuretype can't have target"))
  end
end
