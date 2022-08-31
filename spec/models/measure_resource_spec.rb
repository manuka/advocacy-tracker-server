require "rails_helper"

RSpec.describe MeasureResource, type: :model do
  it { is_expected.to belong_to :resource }
  it { is_expected.to belong_to :resource }
  it { is_expected.to validate_presence_of :resource_id }
  it { is_expected.to validate_presence_of :measure_id }

  context "with a measure and a resource" do
    let(:measure) { FactoryBot.create(:measure) }
    let(:resource) { FactoryBot.create(:resource) }

    subject { described_class.create(measure: measure, resource: resource) }

    it "create sets the relationship_updated_at on the measure" do
      expect { subject }.to change { measure.reload.relationship_updated_at }
    end

    it "update sets the relationship_updated_at on the measure" do
      subject
      expect { subject.touch }.to change { measure.reload.relationship_updated_at }
    end

    it "destroy sets the relationship_updated_at on the measure" do
      expect { subject.destroy }.to change { measure.reload.relationship_updated_at }
    end
  end
end
