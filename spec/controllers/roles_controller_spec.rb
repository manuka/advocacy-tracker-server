# frozen_string_literal: true

require "rails_helper"
require "json"

RSpec.describe RolesController, type: :controller do
  describe "Get index" do
    subject { get :index, format: :json }
    let!(:role) { FactoryBot.create(:role) }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:user) { FactoryBot.create(:user, :manager) }
      let(:admin) { FactoryBot.create(:user, :admin) }

      it "guest will not see roles" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "manager will see roles" do
        sign_in user
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(2)
      end

      it "admin will see roles" do
        sign_in user
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(2)
      end
    end
  end

  describe "Get show" do
    let(:role) { FactoryBot.create(:role) }
    subject { get :show, params: {id: role}, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end
  end

  describe "Post create" do
    context "when not signed in" do
      it "not allow creating a role" do
        post :create, format: :json, params: {role: {name: "test", friendly_name: "test"}}
        expect(response).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:admin) { FactoryBot.create(:user, :admin) }

      subject do
        post :create, format: :json, params: {role: {name: "test", friendly_name: "test"}}
      end

      it "will not allow a guest to create a role" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow a manager to create a role" do
        sign_in manager
        expect(subject).to be_forbidden
      end

      it "will not allow an admin to create a role" do
        sign_in admin
        expect(subject).to be_forbidden
      end
    end
  end

  describe "PUT update" do
    let(:role) { FactoryBot.create(:role) }
    subject do
      put :update,
        format: :json,
        params: {id: role.id, role: {name: "test", friendly_name: "test"}}
    end

    context "when not signed in" do
      it "not allow updating a role" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:admin) { FactoryBot.create(:user, :admin) }

      it "will not allow a guest to update a role" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow a manager to update a role" do
        sign_in manager
        expect(subject).to be_forbidden
      end

      it "will not allow an admin to update a role" do
        sign_in admin
        expect(subject).to be_forbidden
      end
    end
  end

  describe "Delete destroy" do
    let(:role) { FactoryBot.create(:role) }
    subject { delete :destroy, format: :json, params: {id: role} }

    context "when not signed in" do
      it "not allow deleting a role" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:admin) { FactoryBot.create(:user, :admin) }

      it "will not allow a guest to delete a role" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow a manager to delete a role" do
        sign_in manager
        expect(subject).to be_forbidden
      end

      it "will not allow a admin to delete a role" do
        sign_in admin
        expect(subject).to be_forbidden
      end
    end
  end
end
