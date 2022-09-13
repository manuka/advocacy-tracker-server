require "rails_helper"

RSpec.describe Measuretype, type: :model do
  it { is_expected.to validate_presence_of :title }
  it { is_expected.to have_many :measures }

  it "is expected to default notifications to false" do
    expect(subject.notifications).to eq(false)
  end
end
