# frozen_string_literal: true

require "rails_helper"
require "json"

RSpec.describe IndicatorsController, type: :controller do
  let(:admin) { FactoryBot.create(:user, :admin) }
  let(:analyst) { FactoryBot.create(:user, :analyst) }
  let(:guest) { FactoryBot.create(:user) }
  let(:manager) { FactoryBot.create(:user, :manager) }

  describe "Get index" do
    subject { get :index, format: :json }
    let!(:indicator) { FactoryBot.create(:indicator) }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end

    context "when signed in" do
      it "guest will be forbidden" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      context "draft" do
        let!(:draft_indicator) { FactoryBot.create(:indicator, draft: true) }

        it "admin will see draft indicators" do
          sign_in admin
          json = JSON.parse(subject.body)
          expect(json["data"].length).to eq(2)
        end

        it "manager will see draft indicators" do
          sign_in manager
          json = JSON.parse(subject.body)
          expect(json["data"].length).to eq(2)
        end
      end
    end

    context "filters" do
      let(:measure) { FactoryBot.create(:measure) }
      let(:indicator_different_measure) { FactoryBot.create(:indicator) }

      context "when signed in" do
        it "filters from measures" do
          sign_in manager
          indicator_different_measure.measures << measure
          subject = get :index, params: {measure_id: measure.id}, format: :json
          json = JSON.parse(subject.body)
          expect(json["data"].length).to eq(1)
          expect(json["data"][0]["id"]).to eq(indicator_different_measure.id.to_s)
        end
      end
    end
  end

  describe "Get show" do
    let(:indicator) { FactoryBot.create(:indicator) }
    let(:draft_indicator) { FactoryBot.create(:indicator, draft: true) }
    subject { get :show, params: {id: indicator}, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end
  end

  describe "Post create" do
    context "when not signed in" do
      it "not allow creating a indicator" do
        post :create, format: :json, params: {indicator: {title: "test", description: "test", target_date: "today"}}
        expect(response).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:measure) { FactoryBot.create(:measure) }
      subject do
        post :create,
          format: :json,
          params: {
            indicator: {
              title: "test",
              description: "test",
              target_date: "today"
            }
          }
      end

      it "will not allow a guest to create a indicator" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will allow a manager to create a indicator" do
        sign_in manager
        expect(subject).to be_created
      end

      it "will record what manager created the indicator", versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json["data"]["attributes"]["updated_by_id"].to_i).to eq manager.id
      end

      it "will return an error if params are incorrect" do
        sign_in manager
        post :create, format: :json, params: {indicator: {description: "desc only"}}
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "PUT update" do
    let!(:indicator) { FactoryBot.create(:indicator) }
    subject do
      put :update,
        format: :json,
        params: {id: indicator,
                 indicator: {title: "test update", description: "test update", target_date: "today update"}}
    end

    context "when not signed in" do
      it "not allow updating a indicator" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      it "will not allow a guest to update a indicator" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will allow a manager to update a indicator" do
        sign_in manager
        expect(subject).to be_ok
      end

      it "will reject an update where the last_updated_at is older than updated_at in the database" do
        sign_in manager
        indicator_get = get :show, params: {id: indicator}, format: :json
        json = JSON.parse(indicator_get.body)
        current_update_at = json["data"]["attributes"]["updated_at"]

        Timecop.travel(Time.new + 15.days) do
          subject = put :update,
            format: :json,
            params: {id: indicator,
                     indicator: {title: "test update", description: "test updateeee", target_date: "today update", updated_at: current_update_at}}
          expect(subject).to be_ok
        end
        Timecop.travel(Time.new + 5.days) do
          subject = put :update,
            format: :json,
            params: {id: indicator,
                     indicator: {title: "test update", description: "test updatebbbb", target_date: "today update", updated_at: current_update_at}}
          expect(subject).to_not be_ok
        end
      end

      it "will record what manager updated the indicator", versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json["data"]["attributes"]["updated_by_id"].to_i).to eq manager.id
      end

      it "will return the latest updated_by", versioning: true do
        expect(PaperTrail).to be_enabled
        indicator.versions.first.update_column(:whodunnit, admin.id)
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json["data"]["attributes"]["updated_by_id"].to_i).to eq(manager.id)
      end

      it "will return an error if params are incorrect" do
        sign_in manager
        put :update, format: :json, params: {id: indicator, indicator: {title: ""}}
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "Delete destroy" do
    let(:indicator) { FactoryBot.create(:indicator) }
    subject { delete :destroy, format: :json, params: {id: indicator} }

    context "when not signed in" do
      it "not allow deleting a indicator" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      it "will not allow a guest to delete a indicator" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will allow a manager to delete a indicator" do
        sign_in manager
        expect(subject).to be_no_content
      end
    end
  end
end
