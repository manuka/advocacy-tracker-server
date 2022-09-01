# frozen_string_literal: true

require "rails_helper"
require "json"

RSpec.describe MeasuresController, type: :controller do
  let(:admin) { FactoryBot.create(:user, :admin) }
  let(:analyst) { FactoryBot.create(:user, :analyst) }
  let(:guest) { FactoryBot.create(:user) }
  let(:manager) { FactoryBot.create(:user, :manager) }

  describe "GET index" do
    subject { get :index, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end

    context "when signed in" do
      it "guest will be forbidden" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      context "draft" do
        let!(:measure) { FactoryBot.create(:measure) }
        let!(:draft_measure) { FactoryBot.create(:measure, draft: true) }

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

      context "is_archive measures" do
        let!(:measure) { FactoryBot.create(:measure, :not_is_archive) }
        let!(:is_archive_measure) { FactoryBot.create(:measure, :is_archive) }

        it "admin will see" do
          sign_in admin
          json = JSON.parse(subject.body)
          expect(json["data"].length).to eq(2)
        end

        it "manager will not see" do
          sign_in manager
          json = JSON.parse(subject.body)
          expect(json["data"].length).to eq(1)
        end

        it "analyst will not see" do
          sign_in analyst

          json = JSON.parse(subject.body)
          expect(json["data"].length).to eq(1)
        end
      end

      context "private" do
        let!(:measure) { FactoryBot.create(:measure, :not_private) }
        let!(:private_measure) { FactoryBot.create(:measure, :private) }
        let!(:private_measure_by_manager) { FactoryBot.create(:measure, :private, created_by_id: manager.id) }

        it "admin will see" do
          sign_in admin
          json = JSON.parse(subject.body)
          expect(json["data"].length).to eq(3)
        end

        it "manager who created will see" do
          sign_in manager
          json = JSON.parse(subject.body)
          expect(json["data"].length).to eq(2)
        end

        it "manager who didn't create will not see" do
          sign_in FactoryBot.create(:user, :manager)
          json = JSON.parse(subject.body)
          expect(json["data"].length).to eq(1)
        end
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

  describe "GET show" do
    let(:measure) { FactoryBot.create(:measure) }
    let(:draft_measure) { FactoryBot.create(:measure, draft: true) }
    let(:private_measure) { FactoryBot.create(:measure, :private) }
    let(:private_measure_by_manager) { FactoryBot.create(:measure, :private, created_by_id: manager.id) }
    let(:requested_resource) { measure }

    subject { get :show, params: {id: requested_resource}, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end

    context "when signed in" do
      context "as admin" do
        before { sign_in admin }

        it { expect(subject).to be_ok }
      end

      context "as manager" do
        before { sign_in manager }

        it { expect(subject).to be_ok }

        context "who created will see" do
          let(:requested_resource) { private_measure_by_manager }

          it { expect(subject).to be_ok }
        end

        context "who didn't create won't see" do
          let(:requested_resource) { private_measure }

          it { expect(subject).to be_not_found }
        end
      end
    end
  end

  describe "POST create" do
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
      let(:params) do
        {
          measure: {
            title: "test",
            description: "test",
            measuretype_id: measuretype.id,
            target_date: "today"
          }
        }
      end

      subject { post :create, format: :json, params: params }

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

      context "is_archive" do
        let(:params) do
          {
            measure: {
              title: "test",
              description: "test",
              measuretype_id: measuretype.id,
              target_date: "today",
              is_archive: true
            }
          }
        end

        it "can't be set by manager" do
          sign_in manager
          expect(subject).to be_created
          expect(JSON.parse(subject.body).dig("data", "attributes", "is_archive")).to eq false
        end

        it "can be set by admin" do
          sign_in admin
          expect(subject).to be_created
          expect(JSON.parse(subject.body).dig("data", "attributes", "is_archive")).to eq true
        end
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

      context "with a successful update to a task measure" do
        let(:measure) { FactoryBot.create(:measure, notifications: true) }
        let!(:user_measure) { FactoryBot.create(:user_measure, user: manager, measure: measure) }

        before do
          allow_any_instance_of(Measure).to receive(:task?).and_return(true)
          sign_in admin
        end

        %w[
          amount_comment
          amount
          code
          comment
          date_comment
          description
          has_reference_landbased_ml
          indicator_summary
          outcome
          private
          reference_landbased_ml
          reference_ml
          status_comment
          status_lbs_protocol
          target_comment
          target_date_comment
          target_date
          title
          url
        ].each do |attr|
          context "when the task is published" do
            let(:measure) { FactoryBot.create(:measure, :published, notifications: true) }

            it "notifies the user of an update to #{attr}" do
              expect {
                put :update, format: :json, params: {id: measure, measure: {attr => "test"}}
              }.to change { ActionMailer::Base.deliveries.count }.by(1)
            end
          end

          context "when the task is draft" do
            let(:measure) { FactoryBot.create(:measure, :draft, notifications: true) }

            it "does not notify the user of an update to #{attr}" do
              expect {
                put :update, format: :json, params: {id: measure, measure: {attr => "test"}}
              }.not_to change { ActionMailer::Base.deliveries.count }.from(0)
            end
          end

          context "when the task is archived" do
            let(:measure) { FactoryBot.create(:measure, :is_archive, notifications: true) }

            it "does not notify the user of an update to #{attr}" do
              expect {
                put :update, format: :json, params: {id: measure, measure: {attr => "test"}}
              }.not_to change { ActionMailer::Base.deliveries.count }.from(0)
            end

            context "and is updated to not archived" do
              it "does notify the user of an update to #{attr}" do
                expect {
                  put :update, format: :json, params: {id: measure, measure: {attr => "test", :is_archive => false}}
                }.to change { ActionMailer::Base.deliveries.count }.by(1)
              end
            end
          end

          context "when the task is updated from draft" do
            let(:measure) { FactoryBot.create(:measure, :draft, notifications: true) }

            it "does not notify the user of an update to #{attr}" do
              expect {
                put :update, format: :json, params: {id: measure, measure: {attr => "test", :draft => false}}
              }.not_to change { ActionMailer::Base.deliveries.count }.from(0)
            end
          end
        end
      end

      context "is_archive" do
        subject do
          put :update, format: :json, params: {id: measure, measure: {is_archive: true}}
        end

        it "can't be set by manager" do
          sign_in manager
          expect(JSON.parse(subject.body).dig("data", "attributes", "is_archive")).to eq false
        end

        it "can be set by admin" do
          sign_in admin
          expect(JSON.parse(subject.body).dig("data", "attributes", "is_archive")).to eq true
        end
      end

      it "will reject an update where the last_updated_at is older than updated_at in the database" do
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

  describe "DELETE destroy" do
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
