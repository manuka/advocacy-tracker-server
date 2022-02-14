require "rails_helper"

RSpec.describe UserActor, type: :model do
  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :actor }
  # handled by postgres
  # it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:actor_id) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:actor_id) }
end
