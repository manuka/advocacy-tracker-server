require "rails_helper"
require "json"

RSpec.describe RecommendationIndicatorsController, type: :controller do
  let(:guest) { FactoryBot.create(:user) }
  let(:coordinator) { FactoryBot.create(:user, :coordinator) }
  let(:manager) { FactoryBot.create(:user, :manager) }
  let(:admin) { FactoryBot.create(:user, :admin) }

  describe "index" do
    subject { get :index, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end
  end

  describe "show" do
    let(:recommendation_indicator) { FactoryBot.create(:recommendation_indicator) }
    subject { get :show, params: {id: recommendation_indicator}, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end
  end

  describe "create" do
    context "when not signed in" do
      it "doesnt allow creating a recommendation_indicator" do
        post :create, format: :json, params: {recommendation_indicator: {recommendation_id: 1, indicator_id: 1}}
        expect(response).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:recommendation) { FactoryBot.create(:recommendation) }
      let(:indicator) { FactoryBot.create(:indicator) }

      subject do
        post :create,
          format: :json,
          params: {
            recommendation_indicator: {
              recommendation_id: recommendation.id,
              indicator_id: indicator.id
            }
          }
      end

      it "wont allow a guest to create a recommendation_indicator" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will allow a manager to create a recommendation_indicator" do
        sign_in manager
        expect(subject).to be_created
      end

      it "will allow a coordinator to create a recommendation_indicator" do
        sign_in coordinator
        expect(subject).to be_created
      end

      it "will allow an admin to create a recommendation_indicator" do
        sign_in admin
        expect(subject).to be_created
      end

      it "will return an error if params are incorrect" do
        sign_in manager
        post :create, format: :json, params: {recommendation_indicator: {description: "desc"}}
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "destroy" do
    let(:recommendation_indicator) { FactoryBot.create(:recommendation_indicator) }
    subject { delete :destroy, format: :json, params: {id: recommendation_indicator} }

    context "when not signed in" do
      it "wont allow deleting a recommendation_indicator" do
        expect(subject).to be_unauthorized
      end
    end

    context "when signed in" do
      it "wont allow a guest to delete a recommendation_indicator" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will allow a manager to delete a recommendation_indicator" do
        sign_in manager
        expect(subject).to be_no_content
      end

      it "will allow a coordinator to delete a recommendation_indicator" do
        sign_in coordinator
        expect(subject).to be_no_content
      end

      it "will allow an admin to delete a recommendation_indicator" do
        sign_in admin
        expect(subject).to be_no_content
      end
    end
  end
end
