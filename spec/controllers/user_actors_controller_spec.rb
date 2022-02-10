require "rails_helper"
require "json"

RSpec.describe UserActorsController, type: :controller do
  describe "Get index" do
    subject { get :index, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end
  end

  describe "Get show" do
    let(:user_actor) { FactoryBot.create(:user_actor) }
    subject { get :show, params: {id: user_actor}, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end
  end

  describe "Post create" do
    context "when not signed in" do
      it "not allow creating a user_actor" do
        post :create, format: :json, params: {user_actor: {user_id: 1, actor_id: 1}}
        expect(response).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:user) { FactoryBot.create(:user) }
      let(:actor) { FactoryBot.create(:actor) }

      subject do
        post :create,
          format: :json,
          params: {
            user_actor: {
              user_id: user.id,
              actor_id: actor.id
            }
          }
      end

      it "will not allow a guest to create a user_actor" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will allow a manager to create a user_actor" do
        sign_in manager
        expect(subject).to be_created
      end

      it "will return an error if params are incorrect" do
        sign_in manager
        post :create, format: :json, params: {user_actor: {description: "desc only", taxonomy_id: 999}}
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "Delete destroy" do
    let(:user_actor) { FactoryBot.create(:user_actor) }
    subject { delete :destroy, format: :json, params: {id: user_actor} }

    context "when not signed in" do
      it "not allow deleting a user_actor" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:user) { FactoryBot.create(:user, :manager) }

      it "will not allow a guest to delete a user_actor" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will allow a manager to delete a user_actor" do
        sign_in user
        expect(subject).to be_no_content
      end
    end
  end
end
