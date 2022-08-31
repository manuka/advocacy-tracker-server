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

  context "with an actor and a measure" do
    let(:actor) { FactoryBot.create(:actor) }
    let(:measure) { FactoryBot.create(:measure) }

    subject { described_class.create(actor: actor, measure: measure) }

    it "create sets the relationship_updated_at on the actor" do
      expect { subject }.to change { actor.reload.relationship_updated_at }
    end

    it "create sets the relationship_updated_at on the measure" do
      expect { subject }.to change { measure.reload.relationship_updated_at }
    end

    it "update sets the relationship_updated_at on the actor" do
      subject
      expect { subject.touch }.to change { actor.reload.relationship_updated_at }
    end

    it "update sets the relationship_updated_at on the measure" do
      subject
      expect { subject.touch }.to change { measure.reload.relationship_updated_at }
    end

    it "destroy sets the relationship_updated_at on the actor" do
      expect { subject.destroy }.to change { actor.reload.relationship_updated_at }
    end

    it "destroy sets the relationship_updated_at on the measure" do
      expect { subject.destroy }.to change { measure.reload.relationship_updated_at }
    end
  end
end
