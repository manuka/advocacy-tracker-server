# frozen_string_literal: true

require "rails_helper"
require "json"

RSpec.describe ProgressReportsController, type: :controller do
  describe "Get index" do
    subject { get :index, format: :json }
    let!(:progress_report) { FactoryBot.create(:progress_report) }
    let!(:draft_progress_report) { FactoryBot.create(:progress_report, draft: true) }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end

    context "when signed in" do
      let(:coordinator) { FactoryBot.create(:user, :coordinator) }
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }

      it "guest will be forbidden" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "manager will see draft progress_reports" do
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(2)
      end

      it "coordinator will see draft progress_reports" do
        sign_in coordinator
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(2)
      end
    end
  end

  describe "Get show" do
    let(:progress_report) { FactoryBot.create(:progress_report) }
    let(:draft_progress_report) { FactoryBot.create(:progress_report, draft: true) }
    subject { get :show, params: {id: progress_report}, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end
  end

  describe "Post create" do
    context "when not signed in" do
      it "not allow creating a progress_report" do
        post :create, format: :json, params: {progress_report: {title: "test",
                                                                description: "test",
                                                                target_date: "today"}}
        expect(response).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:coordinator) { FactoryBot.create(:user, :coordinator) }
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:due_date) { FactoryBot.create(:due_date) }
      let(:indicator) { FactoryBot.create(:indicator) }

      subject do
        post :create,
          format: :json,
          params: {
            progress_report: {
              indicator_id: indicator.id,
              due_date_id: due_date.id,
              title: "test title",
              description: "test desc",
              document_url: "test_url",
              document_public: true
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

      it "will not allow a guest to create a progress_report" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will allow a manager to create a progress_report" do
        sign_in manager
        expect(subject).to be_created
      end

      it "will allow a coordinator to create a progress_report" do
        sign_in coordinator
        expect(subject).to be_created
      end

      it "will record what manager created the progress_report", versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json["data"]["attributes"]["updated_by_id"].to_i).to eq manager.id
      end

      it "will return an error if params are incorrect" do
        sign_in manager
        post :create, format: :json, params: {progress_report: {description: "desc only"}}
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "PUT update" do
    let(:progress_report) { FactoryBot.create(:progress_report) }

    subject do
      put :update,
        format: :json,
        params: {id: progress_report,
                 progress_report: {title: "test update", description: "test update"}}
    end

    context "when not signed in" do
      it "not allow updating a progress_report" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:admin) { FactoryBot.create(:user, :admin) }
      let(:coordinator) { FactoryBot.create(:user, :coordinator) }
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:admin_indicator) { FactoryBot.create(:indicator, manager: admin) }
      let(:progress_report_with_admin) { FactoryBot.create(:progress_report, indicator: admin_indicator) }

      subject(:with_admin_manager) do
        put :update,
          format: :json,
          params: {id: progress_report_with_admin,
                   progress_report: {title: "test update", description: "test update"}}
      end

      it "will not allow a guest to update a progress_report" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will allow a manager to update a progress_report" do
        sign_in manager
        expect(subject).to be_ok
      end

      it "will allow a coordinator to update a progress_report" do
        sign_in coordinator
        expect(subject).to be_ok
      end

      it "will reject an update where the last_updated_at is older than updated_at in the database" do
        sign_in manager
        progress_report_get = get :show, params: {id: progress_report_with_admin}, format: :json
        json = JSON.parse(progress_report_get.body)
        current_update_at = json["data"]["attributes"]["updated_at"]

        Timecop.travel(Time.new + 15.days) do
          subject = put :update,
            format: :json,
            params: {id: progress_report_with_admin,
                     progress_report: {title: "test update", description: "test updateeee", target_date: "today update", updated_at: current_update_at}}
          expect(subject).to be_ok
        end
        Timecop.travel(Time.new + 5.days) do
          subject = put :update,
            format: :json,
            params: {id: progress_report_with_admin,
                     progress_report: {title: "test update", description: "test updatebbbb", target_date: "today update", updated_at: current_update_at}}
          expect(subject).to_not be_ok
        end
      end

      it "will record what manager updated the progress_report", versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json["data"]["attributes"]["updated_by_id"].to_i).to eq manager.id
      end

      it "will return the latest updated_by", versioning: true do
        expect(PaperTrail).to be_enabled
        progress_report.versions.first.update_column(:whodunnit, admin.id)
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json["data"]["attributes"]["updated_by_id"].to_i).to eq(manager.id)
      end

      it "will return an error if params are incorrect" do
        sign_in manager
        put :update, format: :json, params: {id: progress_report, progress_report: {title: ""}}
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "Delete destroy" do
    let(:progress_report) { FactoryBot.create(:progress_report) }
    subject { delete :destroy, format: :json, params: {id: progress_report} }

    context "when not signed in" do
      it "not allow deleting a progress_report" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:coordinator) { FactoryBot.create(:user, :coordinator) }
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }

      it "will not allow a guest to delete a progress_report" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will allow a manager to delete a progress_report" do
        sign_in manager
        expect(subject).to be_no_content
      end

      it "will allow a coordinator to delete a progress_report" do
        sign_in coordinator
        expect(subject).to be_no_content
      end
    end
  end
end
