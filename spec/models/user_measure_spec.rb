require "rails_helper"

RSpec.describe UserMeasure, type: :model do
  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :measure }
  # handled by postgres
  # it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:measure_id) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:measure_id) }

  context "with a user and a measure" do
    let(:user) { FactoryBot.create(:user) }
    let(:measure) { FactoryBot.create(:measure) }

    let(:whodunnit) { FactoryBot.create(:user).id }
    before { allow(::PaperTrail.request).to receive(:whodunnit).and_return(whodunnit) }

    subject { described_class.create(user: user, measure: measure) }

    it "create sets the relationship_updated_at on the user" do
      expect { subject }.to change { user.reload.relationship_updated_at }
    end

    it "create sets the relationship_updated_at on the measure" do
      expect { subject }.to change { measure.reload.relationship_updated_at }
    end

    it "update sets the relationship_updated_at on the user" do
      subject
      expect { subject.touch }.to change { user.reload.relationship_updated_at }
    end

    it "update sets the relationship_updated_at on the measure" do
      subject
      expect { subject.touch }.to change { measure.reload.relationship_updated_at }
    end

    it "destroy sets the relationship_updated_at on the user" do
      expect { subject.destroy }.to change { user.reload.relationship_updated_at }
    end

    it "destroy sets the relationship_updated_at on the measure" do
      expect { subject.destroy }.to change { measure.reload.relationship_updated_at }
    end

    it "create sets the relationship_updated_by_id on the user" do
      expect { subject }.to change { user.reload.relationship_updated_by_id }.to(whodunnit)
    end

    it "create sets the relationship_updated_by_id on the measure" do
      expect { subject }.to change { measure.reload.relationship_updated_by_id }.to(whodunnit)
    end

    it "update sets the relationship_updated_by_id on the user" do
      subject
      user.update_column(:relationship_updated_by_id, nil)
      expect { subject.touch }.to change { user.reload.relationship_updated_by_id }.to(whodunnit)
    end

    it "update sets the relationship_updated_by_id on the measure" do
      subject
      measure.update_column(:relationship_updated_by_id, nil)
      expect { subject.touch }.to change { measure.reload.relationship_updated_by_id }.to(whodunnit)
    end

    it "destroy sets the relationship_updated_by_id on the user" do
      expect { subject.destroy }.to change { user.reload.relationship_updated_by_id }.to(whodunnit)
    end

    it "destroy sets the relationship_updated_by_id on the measure" do
      expect { subject.destroy }.to change { measure.reload.relationship_updated_by_id }.to(whodunnit)
    end
  end
end
