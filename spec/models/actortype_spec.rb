require "rails_helper"

RSpec.describe Actortype, type: :model do
  it { is_expected.to validate_presence_of :title }
  it { is_expected.to have_many :actors }

  it "is expected to default has_members to false" do
    expect(subject.has_members).to eq(false)
  end

  it "is expected to default is_active to false" do
    expect(subject.is_active).to eq(false)
  end

  it "is expected to default is_target to false" do
    expect(subject.is_target).to eq(false)
  end
end
