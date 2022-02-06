require "rails_helper"

RSpec.describe MeasureCategory, type: :model do
  it { is_expected.to belong_to :measure }
  it { is_expected.to belong_to :category }
  it { is_expected.to validate_uniqueness_of(:category_id).scoped_to(:measure_id) }
  it { is_expected.to validate_presence_of :category_id }
  it { is_expected.to validate_presence_of :measure_id }

  let(:category) { FactoryBot.create(:category) }
  let(:measure) { FactoryBot.create(:measure) }

  it "errors when the category's taxonomy is not enabled for its measuretype" do
    measure_category = described_class.create(category: category, measure: measure)
    expect(measure_category).to be_invalid
    expect(measure_category.errors[:measure_id]).to include("must have the category's taxonomy enabled for its measuretype")
  end

  it "works when the category's taxonomy is enabled for its measuretype" do
    FactoryBot.create(:measuretype_taxonomy, measuretype: measure.measuretype, taxonomy: category.taxonomy)

    measure_category = described_class.create(category: category, measure: measure)
    expect(measure_category).to be_valid
  end
end
