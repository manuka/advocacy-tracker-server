require "rails_helper"

RSpec.describe Framework, type: :model do
  it { is_expected.to validate_presence_of :title }
  it { is_expected.to have_many :frameworks }
  it { is_expected.to have_many :framework_taxonomies }
  it { is_expected.to have_many :taxonomies }
  it { is_expected.to have_many :recommendations }
  it { is_expected.to have_many :framework_frameworks }

  it "is expected to cascade destroy dependent relationships" do
    framework = FactoryBot.create(:framework_framework).framework
    FactoryBot.create(:framework_taxonomy, framework: framework)

    expect { framework.destroy }.to change {
      [Framework.count, FrameworkFramework.count, FrameworkTaxonomy.count]
    }.from([2, 1, 1]).to([1, 0, 0])
  end
end
