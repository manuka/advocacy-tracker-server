require "rails_helper"

RSpec.describe Resource, type: :model do
  it { is_expected.to validate_presence_of :title }
  it { is_expected.to belong_to :resourcetype }

  it "is expected to default private to false" do
    expect(subject.private).to eq(false)
  end
end
