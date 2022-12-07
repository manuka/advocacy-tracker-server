require "rails_helper"
require "json"

RSpec.describe MeasureResourcesController, type: :controller do
  let(:measure) { FactoryBot.create(:measure) }
  let(:resource) { FactoryBot.create(:resource) }

  describe "Get index" do
    subject { get :index, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end
  end

  describe "Get show" do
    let(:measure_resource) { FactoryBot.create(:measure_resource, resource: resource, measure: measure) }
    subject { get :show, params: {id: measure_resource}, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end
  end

  describe "Post create" do
    context "when not signed in" do
      it "not allow creating a measure_resource" do
        post :create, format: :json, params: {measure_resource: {measure_id: 1, resource_id: 1}}
        expect(response).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:coordinator) { FactoryBot.create(:user, :coordinator) }
      let(:guest) { FactoryBot.create(:user) }
      let(:user) { FactoryBot.create(:user, :manager) }

      subject do
        post :create,
          format: :json,
          params: {
            measure_resource: {
              measure_id: measure.id,
              resource_id: resource.id
            }
          }
      end

      it "will not allow a guest to create a measure_resource" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will allow a manager to create a measure_resource" do
        sign_in user
        expect(subject).to be_created
      end

      it "will allow a coordinator to create a measure_resource" do
        sign_in coordinator
        expect(subject).to be_created
      end

      it "will return an error if params are incorrect" do
        sign_in user
        post :create, format: :json, params: {measure_resource: {description: "desc only", taxonomy_id: 999}}
        expect(response).to have_http_status(422)
      end

      it "will record what manager created the measure resource", versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in user
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "updated_by_id").to_i).to eq user.id
      end
    end
  end

  describe "Delete destroy" do
    let(:measure_resource) { FactoryBot.create(:measure_resource, resource: resource, measure: measure) }
    subject { delete :destroy, format: :json, params: {id: measure_resource} }

    context "when not signed in" do
      it "not allow deleting a measure_resource" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:coordinator) { FactoryBot.create(:user, :coordinator) }
      let(:guest) { FactoryBot.create(:user) }
      let(:user) { FactoryBot.create(:user, :manager) }

      it "will not allow a guest to delete a measure_resource" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will allow a manager to delete a measure_resource" do
        sign_in user
        expect(subject).to be_no_content
      end

      it "will allow a coordinator to delete a measure_resource" do
        sign_in coordinator
        expect(subject).to be_no_content
      end
    end
  end
end
