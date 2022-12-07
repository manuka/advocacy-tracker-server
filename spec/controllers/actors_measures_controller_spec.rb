require "rails_helper"
require "json"

RSpec.describe ActorMeasuresController, type: :controller do
  let(:analyst) { FactoryBot.create(:user, :analyst) }
  let(:coordinator) { FactoryBot.create(:user, :coordinator) }
  let(:guest) { FactoryBot.create(:user) }
  let(:user) { FactoryBot.create(:user, :manager) }

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
    let(:actor_measure) { FactoryBot.create(:actor_measure) }
    subject { get :show, params: {id: actor_measure}, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end

    context "when signed in" do
      context "as analyst" do
        before { sign_in FactoryBot.create(:user, :analyst) }

        it { expect(subject).to be_ok }
      end

      context "as coordinator" do
        before { sign_in FactoryBot.create(:user, :coordinator) }

        it { expect(subject).to be_ok }
      end

      context "as manager" do
        before { sign_in FactoryBot.create(:user, :manager) }

        it { expect(subject).to be_ok }
      end

      context "as admin" do
        before { sign_in FactoryBot.create(:user, :admin) }

        it { expect(subject).to be_ok }
      end
    end
  end

  describe "PUT update" do
    let(:actor_measure) { FactoryBot.create(:actor_measure) }
    subject do
      put :update,
        format: :json,
        params: {id: actor_measure,
                 actor_measure: {value: "4.2"}}
    end

    context "when not signed in" do
      it "not allow updating an actor_measure" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      it "will not allow a guest to update an actor_measure" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow an analyst to update an actor_measure" do
        sign_in analyst
        expect(subject).to be_forbidden
      end

      it "will allow a coordinator to update an actor_measure" do
        sign_in coordinator
        expect(subject).to be_ok
        json = JSON.parse(response.body)
        expect(json.dig("data", "attributes", "value")).to eq("4.2")
      end

      it "will allow a manager to update an actor_measure" do
        sign_in user
        expect(subject).to be_ok
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "value")).to eq("4.2")
      end

      it "will return an error if params are incorrect" do
        sign_in user
        put :update, format: :json, params: {id: actor_measure,
                                             actor_measure: {actor_id: 999}}
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "Delete destroy" do
    let(:actor_measure) { FactoryBot.create(:actor_measure) }
    subject { delete :destroy, format: :json, params: {id: actor_measure} }

    context "when not signed in" do
      it "not allow deleting an actor_measure" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      it "will not allow a guest to delete an actor_measure" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow an analyst to delete an actor_measure" do
        sign_in analyst
        expect(subject).to be_forbidden
      end

      it "will allow a manager to delete an actor_measure" do
        sign_in user
        expect(subject).to be_no_content
      end
    end
  end
end
