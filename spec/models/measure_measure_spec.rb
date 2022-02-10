require "rails_helper"

RSpec.describe MeasureMeasure, type: :model do
  it { is_expected.to belong_to :measure }
  it { is_expected.to belong_to :other_measure }
  # handled by postgres
  # it { is_expected.to validate_uniqueness_of(:measure_id).scoped_to(:other_measure_id) }
  it { is_expected.to validate_presence_of(:measure_id) }
  it { is_expected.to validate_presence_of(:other_measure_id) }
end
