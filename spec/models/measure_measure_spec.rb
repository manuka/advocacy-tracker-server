require "rails_helper"

RSpec.describe MeasureMeasure, type: :model do
  it { is_expected.to belong_to :measure }
  it { is_expected.to belong_to :other_measure }
  # handled by postgres
  # it { is_expected.to validate_uniqueness_of(:measure_id).scoped_to(:other_measure_id) }
  it { is_expected.to validate_presence_of(:measure_id) }
  it { is_expected.to validate_presence_of(:other_measure_id) }

  it "errors when the measure is the same as the other_measure" do
    measure = FactoryBot.create(:measure)
    measure_measure = described_class.create(measure: measure, other_measure: measure)
    expect(measure_measure).to be_invalid
    expect(measure_measure.errors[:measure]).to include("can't be the same as other_measure")
  end
end
