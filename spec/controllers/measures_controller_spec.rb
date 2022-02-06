# frozen_string_literal: true

require "rails_helper"
require "json"

RSpec.describe MeasuresController, type: :controller do
  let(:admin) { FactoryBot.create(:user, :manager) }
  let(:analyst) { FactoryBot.create(:user, :analyst) }
  let(:guest) { FactoryBot.create(:user) }
  let(:manager) { FactoryBot.create(:user, :manager) }

  describe "Get index" do
    subject { get :index, format: :json }
    let!(:measure) { FactoryBot.create(:measure) }
    let!(:draft_measure) { FactoryBot.create(:measure, draft: true) }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end

    context "when signed in" do
      it "guest will be forbidden" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "admin will see draft measures" do
        sign_in admin
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(2)
      end

      it "manager will see draft measures" do
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(2)
      end

      it "analyst will not see draft measures" do
        sign_in analyst

        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(1)
      end
    end

    context "filters" do
      let(:category) { FactoryBot.create(:category) }
      let(:measure_different_category) { FactoryBot.create(:measure) }
      let(:recommendation) { FactoryBot.create(:recommendation) }
      let(:measure_different_recommendation) { FactoryBot.create(:measure) }
      let(:indicator) { FactoryBot.create(:indicator) }
      let(:measure_different_indicator) { FactoryBot.create(:measure) }

      context "when signed in" do
        it "filters from category" do
          sign_in manager
          FactoryBot.create(:measuretype_taxonomy,
            measuretype: measure_different_category.measuretype,
            taxonomy: category.taxonomy)
          measure_different_category.categories << category
          subject = get :index, params: {category_id: category.id}, format: :json
          json = JSON.parse(subject.body)
          expect(json["data"].length).to eq(1)
          expect(json["data"][0]["id"]).to eq(measure_different_category.id.to_s)
        end

        it "filters from recommendation" do
          sign_in manager
          measure_different_recommendation.recommendations << recommendation
          subject = get :index, params: {recommendation_id: recommendation.id}, format: :json
          json = JSON.parse(subject.body)
          expect(json["data"].length).to eq(1)
          expect(json["data"][0]["id"]).to eq(measure_different_recommendation.id.to_s)
        end

        it "filters from indicator" do
          sign_in manager
          measure_different_indicator.indicators << indicator
          subject = get :index, params: {indicator_id: indicator.id}, format: :json
          json = JSON.parse(subject.body)
          expect(json["data"].length).to eq(1)
          expect(json["data"][0]["id"]).to eq(measure_different_indicator.id.to_s)
        end
      end
    end
  end

  describe "Get show" do
    let(:measure) { FactoryBot.create(:measure) }
    let(:draft_measure) { FactoryBot.create(:measure, draft: true) }
    subject { get :show, params: {id: measure}, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end

    context "when signed in" do
      before { sign_in admin }

      it { expect(subject).to be_ok }
    end
  end

  describe "Post create" do
    context "when not signed in" do
      it "not allow creating a measure" do
        post :create, format: :json, params: {measure: {title: "test", description: "test", target_date: "today"}}
        expect(response).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:recommendation) { FactoryBot.create(:recommendation) }
      let(:category) { FactoryBot.create(:category) }
      let(:measuretype) { FactoryBot.create(:measuretype) }

      subject do
        post :create,
          format: :json,
          params: {
            measure: {
              title: "test",
              description: "test",
              measuretype_id: measuretype.id,
              target_date: "today"
            }
          }
        # This is an example creating a new recommendation record in the post
        # post :create,
        #      format: :json,
        #      params: {
        #        measure: {
        #          title: 'test',
        #          description: 'test',
        #          target_date: 'today',
        #          recommendation_measures_attributes: [ { recommendation_attributes: { title: 'test 1', number: 1 } } ]
        #        }
        #      }
      end

      it "will not allow a guest to create a measure" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow an analyst to create a measure" do
        sign_in analyst
        expect(subject).to be_forbidden
      end

      it "will allow a manager to create a measure" do
        sign_in manager
        expect(subject).to be_created
      end

      it "will allow an admin to create a measure" do
        sign_in admin
        expect(subject).to be_created
      end

      it "will record what manager created the measure", versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "updated_by_id").to_i).to eq manager.id
      end

      it "will return an error if params are incorrect" do
        sign_in manager
        post :create, format: :json, params: {measure: {description: "desc only"}}
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "PUT update" do
    let(:measure) { FactoryBot.create(:measure) }
    subject do
      put :update,
        format: :json,
        params: {id: measure,
                 measure: {title: "test update", description: "test update", target_date: "today update"}}
    end

    context "when not signed in" do
      it "not allow updating a measure" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      it "will not allow a guest to update a measure" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow an analyst to update a measure" do
        sign_in analyst
        expect(subject).to be_forbidden
      end

      it "will allow a manager to update a measure" do
        sign_in manager
        expect(subject).to be_ok
      end

      it "will allow an admin to update a measure" do
        sign_in admin
        expect(subject).to be_ok
      end

      it "will reject and update where the last_updated_at is older than updated_at in the database" do
        sign_in manager
        measure_get = get :show, params: {id: measure}, format: :json
        json = JSON.parse(measure_get.body)
        current_update_at = json["data"]["attributes"]["updated_at"]

        Timecop.travel(Time.new + 15.days) do
          subject = put :update,
            format: :json,
            params: {id: measure,
                     measure: {title: "test update", description: "test updateeee", target_date: "today update", updated_at: current_update_at}}
          expect(subject).to be_ok
        end
        Timecop.travel(Time.new + 5.days) do
          subject = put :update,
            format: :json,
            params: {id: measure,
                     measure: {title: "test update", description: "test updatebbbb", target_date: "today update", updated_at: current_update_at}}
          expect(subject).to_not be_ok
        end
      end

      it "will record what manager updated the measure", versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "updated_by_id").to_i).to eq manager.id
      end

      it "will return the latest updated_by", versioning: true do
        expect(PaperTrail).to be_enabled
        measure.versions.first.update_column(:whodunnit, admin.id)
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "updated_by_id").to_i).to eq(manager.id)
      end

      it "will return an error if params are incorrect" do
        sign_in manager
        put :update, format: :json, params: {id: measure, measure: {title: ""}}
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "Delete destroy" do
    let(:measure) { FactoryBot.create(:measure) }
    subject { delete :destroy, format: :json, params: {id: measure} }

    context "when not signed in" do
      it "not allow deleting a measure" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:user) { FactoryBot.create(:user, :manager) }

      it "will not allow a guest to delete a measure" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will allow a manager to delete a measure" do
        sign_in manager
        expect(subject).to be_no_content
      end
    end
  end
end
