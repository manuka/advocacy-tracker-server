require "rails_helper"

RSpec.describe Actor, type: :model do
  it { is_expected.to validate_presence_of :title }
  it { is_expected.to belong_to :actortype }

  it "is expected to default private to true" do
    expect(subject.private).to eq(true)
  end

  it "is expected to default draft to true" do
    expect(subject.draft).to eq(true)
  end

  it "is expected to cascade destroy dependent relationships" do
    actor = FactoryBot.create(:actor)

    taxonomy = FactoryBot.create(:taxonomy, actortype_ids: [actor.actortype_id])
    FactoryBot.create(:actor_category, actor: actor, category: FactoryBot.create(:category, taxonomy: taxonomy))
    FactoryBot.create(:actor_measure, actor: actor)
    FactoryBot.create(:measure_actor, actor: actor)
    FactoryBot.create(:membership, member: actor, memberof: FactoryBot.create(:actor, actortype: FactoryBot.create(:actortype, has_members: true)))

    expect { actor.destroy }.to change {
      [Actor.count, ActorCategory.count, ActorMeasure.count, MeasureActor.count, Membership.count]
    }.from([2, 1, 1, 1, 1]).to([1, 0, 0, 0, 0])
  end
end
