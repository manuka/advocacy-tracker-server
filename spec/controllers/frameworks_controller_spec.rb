require "rails_helper"

RSpec.describe FrameworksController, type: :controller do
  let(:coordinator) { FactoryBot.create(:user, :coordinator) }
  let!(:guest) { FactoryBot.create(:user) }
  let!(:manager) { FactoryBot.create(:user, :manager) }

  describe "index" do
    subject { get :index, format: :json }
    let!(:framework) { FactoryBot.create_list(:framework, 3) }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end

    context "when signed in" do
      it "guest is forbidden" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "returns all frameworks for manager" do
        sign_in manager
        json = JSON.parse(subject.body)
        expect(framework_count(json)).to eq(3)
      end

      it "returns all frameworks for coordinator" do
        sign_in coordinator
        json = JSON.parse(subject.body)
        expect(framework_count(json)).to eq(3)
      end
    end
  end

  describe "show" do
    let!(:framework) { FactoryBot.create(:framework) }
    subject { get :show, params: {id: framework.id}, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end

    context "when signed in" do
      it "guest is forbidden" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "returns the expected framework for manager" do
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json.dig("data", "id").to_i).to eq(framework.id)
      end

      it "returns the expected framework for coordinator" do
        sign_in coordinator
        json = JSON.parse(subject.body)
        expect(json.dig("data", "id").to_i).to eq(framework.id)
      end
    end
  end
end

def framework_count(json)
  json["data"].count { |k| k["type"] == "frameworks" }
end
