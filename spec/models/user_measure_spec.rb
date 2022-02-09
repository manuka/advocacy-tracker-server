require "rails_helper"

RSpec.describe UserMeasure, type: :model do
  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :measure }
  # handled by postgres
  # it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:measure_id) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:measure_id) }
end
