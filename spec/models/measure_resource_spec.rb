require "rails_helper"

RSpec.describe MeasureResource, type: :model do
  it { is_expected.to belong_to :measure }
  it { is_expected.to belong_to :resource }
  it { is_expected.to validate_presence_of :resource_id }
  it { is_expected.to validate_presence_of :measure_id }
end
