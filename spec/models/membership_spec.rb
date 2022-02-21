require "rails_helper"

RSpec.describe Membership, type: :model do
  it { is_expected.to belong_to :member }
  it { is_expected.to belong_to :memberof }

  it "errors when the member is the same as the memberof" do
    member = FactoryBot.create(:actor)
    membership = described_class.create(member: member, memberof: member)
    expect(membership).to be_invalid
    expect(membership.errors[:member]).to include("can't be the same as memberof")
  end

  it "works when the memberof can have members" do
    member = FactoryBot.create(:actor)
    memberof = FactoryBot.create(:actor, actortype: FactoryBot.create(:actortype, :with_members))
    membership = described_class.create(member: member, memberof: memberof)
    expect(membership).to be_valid
  end
end
