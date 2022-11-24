require "rails_helper"
require "json"

RSpec.describe ActortypesController, type: :controller do
  describe "Get index" do
    subject { get :index, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end

    context "when signed in" do
      context "as analyst" do
        before { sign_in FactoryBot.create(:user, :analyst) }

        it { expect(subject).to be_ok }
      end

      context "as manager" do
        before { sign_in FactoryBot.create(:user, :manager) }

        it { expect(subject).to be_ok }
      end

      context "as coordinator" do
        before { sign_in FactoryBot.create(:user, :coordinator) }

        it { expect(subject).to be_ok }
      end

      context "as admin" do
        before { sign_in FactoryBot.create(:user, :admin) }

        it { expect(subject).to be_ok }
      end
    end
  end

  describe "Get show" do
    let(:actortype) { FactoryBot.create(:actortype) }
    subject { get :show, params: {id: actortype}, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end

    context "when signed in" do
      context "as analyst" do
        before { sign_in FactoryBot.create(:user, :analyst) }

        it { expect(subject).to be_ok }
      end

      context "as manager" do
        before { sign_in FactoryBot.create(:user, :manager) }

        it { expect(subject).to be_ok }
      end

      context "as coordinator" do
        before { sign_in FactoryBot.create(:user, :coordinator) }

        it { expect(subject).to be_ok }
      end

      context "as admin" do
        before { sign_in FactoryBot.create(:user, :admin) }

        it { expect(subject).to be_ok }
      end
    end
  end
end
