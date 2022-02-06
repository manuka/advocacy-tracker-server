require "rails_helper"
require "json"

RSpec.describe ResourcesController, type: :controller do
  let(:analyst) { FactoryBot.create(:user, :analyst) }

  describe "Get index" do
    subject { get :index, format: :json }
    let!(:resource) { FactoryBot.create(:resource) }
    let!(:draft_resource) { FactoryBot.create(:resource, draft: true) }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:user) { FactoryBot.create(:user, :manager) }

      context "guest" do
        before { sign_in guest }

        it { expect(subject).to be_forbidden }
      end

      it "manager will see draft resources" do
        sign_in user
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(2)
      end
    end
  end

  describe "Get show" do
    let(:resource) { FactoryBot.create(:resource) }
    let(:draft_resource) { FactoryBot.create(:resource, draft: true) }
    subject { get :show, params: {id: resource}, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }

      it "will not show draft resource" do
        get :show, params: {id: draft_resource}, format: :json
        expect(response).to be_forbidden
      end
    end

    context "when signed in" do
      context "as analyst" do
        context "will show resource" do
          subject { get :show, params: {id: resource}, format: :json }
          before { sign_in analyst }

          it { expect(subject).to be_ok }
        end

        context "will not show draft resource" do
          subject { get :show, params: {id: draft_resource}, format: :json }
          before { sign_in analyst }

          it { expect(subject).to be_not_found }
        end
      end
    end
  end

  describe "Post create" do
    context "when not signed in" do
      it "not allow creating a resource" do
        post :create, format: :json, params: {resource: {title: "test", description: "test", target_date: "today"}}
        expect(response).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:admin) { FactoryBot.create(:user, :admin) }
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:taxonomy) { FactoryBot.create(:taxonomy) }
      let(:resourcetype) { FactoryBot.create(:resourcetype) }

      subject do
        post :create,
          format: :json,
          params: {
            resource: {
              title: "test",
              resourcetype_id: resourcetype.id
            }
          }
      end

      it "will not allow a guest to create a resource" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow an analyst to create a resource" do
        sign_in analyst
        expect(subject).to be_forbidden
      end

      it "will allow a manager to create a resource" do
        sign_in manager
        expect(subject).to be_created
      end

      it "will not allow an admin to create a resource" do
        sign_in admin
        expect(subject).to be_created
      end

      it "will record which admin created the resource", versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in admin
        json = JSON.parse(subject.body)
        expect(json["data"]["attributes"]["updated_by_id"].to_i).to eq admin.id
      end

      it "will return an error if params are incorrect" do
        sign_in admin
        post :create, format: :json, params: {resource: {description: "desc only", taxonomy_id: 999}}
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "PUT update" do
    let(:resource) { FactoryBot.create(:resource) }
    subject do
      put :update,
        format: :json,
        params: {id: resource,
                 resource: {title: "test update", description: "test update", target_date: "today update"}}
    end

    context "when not signed in" do
      it "not allow updating a resource" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:admin) { FactoryBot.create(:user, :admin) }
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }

      it "will not allow a guest to update a resource" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will allow a manager to update a resource" do
        sign_in manager
        expect(subject).to be_ok
      end

      it "will allow an admin to update a resource" do
        sign_in admin
        expect(subject).to be_ok
      end

      it "will reject and update where the last_updated_at is older than updated_at in the database" do
        sign_in admin
        resource_get = get :show, params: {id: resource}, format: :json
        json = JSON.parse(resource_get.body)
        current_update_at = json["data"]["attributes"]["updated_at"]

        Timecop.travel(Time.new + 15.days) do
          subject = put :update,
            format: :json,
            params: {id: resource,
                     resource: {title: "test update", description: "test updateeee", target_date: "today update", updated_at: current_update_at}}
          expect(subject).to be_ok
        end
        Timecop.travel(Time.new + 5.days) do
          subject = put :update,
            format: :json,
            params: {id: resource,
                     resource: {title: "test update", description: "test updatebbbb", target_date: "today update", updated_at: current_update_at}}
          expect(subject).to_not be_ok
        end
      end

      it "will record what manager updated the resource", versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in admin
        json = JSON.parse(subject.body)
        expect(json["data"]["attributes"]["updated_by_id"].to_i).to eq admin.id
      end

      it "will return the latest updated_by", versioning: true do
        expect(PaperTrail).to be_enabled
        resource.versions.first.update_column(:whodunnit, manager.id)
        sign_in admin
        json = JSON.parse(subject.body)
        expect(json["data"]["attributes"]["updated_by_id"].to_i).to eq(admin.id)
      end
    end
  end

  describe "Delete destroy" do
    let(:resource) { FactoryBot.create(:resource) }
    subject { delete :destroy, format: :json, params: {id: resource} }

    context "when not signed in" do
      it "not allow deleting a resource" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:admin) { FactoryBot.create(:user, :admin) }
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }

      it "will not allow a guest to delete a resource" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will allow a manager to delete a resource" do
        sign_in manager
        expect(subject).to be_no_content
      end

      it "will allow an admin to delete a resource" do
        sign_in admin
        expect(subject).to be_no_content
      end
    end
  end
end
