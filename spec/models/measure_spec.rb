require "rails_helper"

RSpec.describe Measure, type: :model do
  it { is_expected.to validate_presence_of :title }
  it { is_expected.to have_many :recommendations }
  it { is_expected.to have_many :categories }
  it { is_expected.to have_many :indicators }
  it { is_expected.to have_many :due_dates }
  it { is_expected.to have_many :progress_reports }

  it "is expected to default private to false" do
    expect(subject.private).to eq(false)
  end

  it "is expected to default notifications to true" do
    expect(subject.notifications).to eq(true)
  end

  context "parent_id" do
    subject do
      described_class.create(
        measuretype: FactoryBot.create(:measuretype, :parent_allowed),
        title: "test"
      )
    end

    it "can be set to a measure with :measuretype.has_parent = true" do
      subject.parent_id = described_class.create(
        measuretype: FactoryBot.create(:measuretype, :parent_allowed),
        title: "no parent"
      ).id
      expect(subject).to be_valid
    end

    it "can't be the record's ID" do
      subject.parent_id = subject.id
      expect(subject).to be_invalid
      expect(subject.errors[:parent_id]).to(include("can't be the same as id"))
    end

    it "can't be set to a measure with :measuretype.has_parent = false" do
      subject.parent_id = described_class.create(
        measuretype: FactoryBot.create(:measuretype, :parent_not_allowed),
        title: "no parent"
      ).id
      expect(subject).to be_invalid
      expect(subject.errors[:parent_id]).to(include("is not allowed for this measuretype"))
    end

    it "can't be its own descendant" do
      child = described_class.create(
        measuretype: FactoryBot.create(:measuretype, :parent_allowed),
        parent_id: subject.id,
        title: "immediate child"
      )
      expect(child).to be_valid
      subject.parent_id = child.id
      expect(subject).to be_invalid
      expect(subject.errors[:parent_id]).to include("can't be its own descendant")
    end

    it "is expected to cascade destroy dependent relationships" do
      measure = FactoryBot.create(:measure)

      taxonomy = FactoryBot.create(:taxonomy, measuretype_ids: [measure.measuretype_id])
      FactoryBot.create(:measure_category, measure: measure, category: FactoryBot.create(:category, taxonomy: taxonomy))
      FactoryBot.create(:measure_indicator, measure: measure)
      FactoryBot.create(:actor_measure, measure: measure)
      FactoryBot.create(:measure_actor, measure: measure)
      FactoryBot.create(:measure_measure, measure: measure)
      FactoryBot.create(:measure_resource, measure: measure)
      FactoryBot.create(:recommendation_measure, measure: measure)
      FactoryBot.create(:user_measure, measure: measure)

      expect { measure.destroy }.to change {
        [
          Measure.count,
          MeasureCategory.count,
          MeasureIndicator.count,
          MeasureMeasure.count,
          MeasureResource.count,
          ActorMeasure.count,
          MeasureActor.count,
          RecommendationMeasure.count,
          UserMeasure.count
        ]
      }.from([2, 1, 1, 1, 1, 1, 1, 1, 1]).to([1, 0, 0, 0, 0, 0, 0, 0, 0])
    end

    it "is expected to cascade destroy other_measure_measures relationships" do
      measure_measure = FactoryBot.create(:measure_measure)

      expect { measure_measure.other_measure.destroy }.to change {
        Measure.count
      }.from(2).to(1)
    end
  end
end
