require "rails_helper"
require "json"

RSpec.describe TaxonomiesController, type: :controller do
  let(:admin) { FactoryBot.create(:user, :admin) }
  let(:analyst) { FactoryBot.create(:user, :analyst) }
  let(:guest) { FactoryBot.create(:user) }
  let(:manager) { FactoryBot.create(:user, :manager) }

  describe "Get index" do
    subject { get :index, format: :json }
    let!(:taxonomy) { FactoryBot.create(:taxonomy) }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end
  end

  describe "Get show" do
    let(:taxonomy) { FactoryBot.create(:taxonomy) }
    subject { get :show, params: {id: taxonomy}, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end
  end

  describe "Post create" do
    context "when not signed in" do
      it "not allow creating a taxonomy" do
        post :create, format: :json, params: {taxonomy: {title: "test", description: "test", target_date: "today"}}
        expect(response).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:taxonomy) { FactoryBot.create(:taxonomy) }

      subject do
        post :create,
          format: :json,
          params: {
            taxonomy: {
              title: "test",
              short_title: "bla",
              description: "test",
              target_date: "today",
              allow_multiple: false,
              tags_measures: false,
              taxonomy_id: taxonomy.id
            }
          }
      end

      it "will not allow a guest to create a taxonomy" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow an analyst to create a taxonomy" do
        sign_in analyst
        expect(subject).to be_forbidden
      end

      it "will not allow a manager to create a taxonomy" do
        sign_in manager
        expect(subject).to be_forbidden
      end

      it "will not allow an admin to create a taxonomy" do
        sign_in admin
        expect(subject).to be_forbidden
      end
    end
  end

  describe "PUT update" do
    let(:taxonomy) { FactoryBot.create(:taxonomy) }
    subject do
      put :update,
        format: :json,
        params: {id: taxonomy,
                 taxonomy: {title: "test update", description: "test update", target_date: "today update"}}
    end

    context "when not signed in" do
      it "not allow updating a taxonomy" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      it "will not allow a guest to update a taxonomy" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow an analyst to update a taxonomy" do
        sign_in analyst
        expect(subject).to be_forbidden
      end

      it "will not allow a manager to update a taxonomy" do
        sign_in manager
        expect(subject).to be_forbidden
      end

      it "will not allow an admin to update a taxonomy" do
        sign_in admin
        expect(subject).to be_forbidden
      end
    end
  end

  describe "Delete destroy" do
    let(:taxonomy) { FactoryBot.create(:taxonomy) }
    subject { delete :destroy, format: :json, params: {id: taxonomy} }

    context "when not signed in" do
      it "not allow deleting a taxonomy" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      it "will not allow a guest to delete a taxonomy" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow an analyst to delete a taxonomy" do
        sign_in analyst
        expect(subject).to be_forbidden
      end

      it "will not allow a manager to delete a taxonomy" do
        sign_in manager
        expect(subject).to be_forbidden
      end

      it "will not allow an admin to delete a taxonomy" do
        sign_in admin
        expect(subject).to be_forbidden
      end
    end
  end
end
