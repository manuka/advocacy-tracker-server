require "rails_helper"
require "json"

RSpec.describe ResourcesController, type: :controller do
  let(:admin) { FactoryBot.create(:user, :admin) }
  let(:analyst) { FactoryBot.create(:user, :analyst) }
  let(:guest) { FactoryBot.create(:user) }
  let(:manager) { FactoryBot.create(:user, :manager) }

  describe "Get index" do
    subject { get :index, format: :json }
    let!(:resource) { FactoryBot.create(:resource) }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end

    context "when signed in" do
      context "guest" do
        before { sign_in guest }

        it { expect(subject).to be_forbidden }
      end

      context "draft" do
        let!(:draft_resource) { FactoryBot.create(:resource, draft: true) }

        it "admin will see draft resources" do
          sign_in admin
          json = JSON.parse(subject.body)
          expect(json["data"].length).to eq(2)
        end

        it "manager will see draft resources" do
          sign_in manager
          json = JSON.parse(subject.body)
          expect(json["data"].length).to eq(2)
        end
      end

      context "is_archive resources" do
        let!(:resource) { FactoryBot.create(:resource, :not_is_archive) }
        let!(:is_archive_resource) { FactoryBot.create(:resource, :is_archive) }

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
        let!(:resource) { FactoryBot.create(:resource, :not_private) }
        let!(:private_resource) { FactoryBot.create(:resource, :private) }
        let!(:private_resource_by_manager) { FactoryBot.create(:resource, :private, created_by_id: manager.id) }

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
  end

  describe "Get show" do
    let(:draft_resource) { FactoryBot.create(:resource, draft: true) }
    let(:private_resource_by_manager) { FactoryBot.create(:resource, :private, created_by_id: manager.id) }
    let(:private_resource) { FactoryBot.create(:resource, :private) }
    let(:requested_resource) { resource }
    let(:resource) { FactoryBot.create(:resource) }
    subject { get :show, params: {id: requested_resource}, format: :json }

    context "when not signed in" do
      let(:requested_resource) { resource }
      it { expect(subject).to be_forbidden }

      context "draft" do
        let(:requested_resource) { draft_resource }

        it "will not show draft resource" do
          expect(subject).to be_forbidden
        end
      end
    end

    context "when signed in" do
      context "as analyst" do
        context "will show resource" do
          let(:requested_resource) { resource }

          before { sign_in analyst }

          it { expect(subject).to be_ok }
        end

        context "will not show draft resource" do
          let(:requested_resource) { draft_resource }

          before { sign_in analyst }

          it { expect(subject).to be_not_found }
        end

        context "as admin" do
          before { sign_in admin }

          it { expect(subject).to be_ok }
        end

        context "as manager" do
          before { sign_in manager }

          it { expect(subject).to be_ok }

          context "who created will see" do
            let(:requested_resource) { private_resource_by_manager }

            it { expect(subject).to be_ok }
          end

          context "who didn't create won't see" do
            let(:requested_resource) { private_resource }

            it { expect(subject).to be_not_found }
          end
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
      let(:taxonomy) { FactoryBot.create(:taxonomy) }
      let(:resourcetype) { FactoryBot.create(:resourcetype) }
      let(:params) do
        {
          resource: {
            title: "test",
            resourcetype_id: resourcetype.id
          }
        }
      end

      subject { post :create, format: :json, params: params }

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

      it "will allow an admin to create a resource" do
        sign_in admin
        expect(subject).to be_created
      end

      context "is_archive" do
        let(:params) do
          {
            resource: {
              title: "test",
              resourcetype_id: resourcetype.id,
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

      context "is_archive" do
        subject do
          put :update, format: :json, params: {id: resource, resource: {is_archive: true}}
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
