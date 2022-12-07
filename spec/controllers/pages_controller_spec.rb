require "rails_helper"
require "json"

RSpec.describe PagesController, type: :controller do
  let(:admin) { FactoryBot.create(:user, :admin) }
  let(:coordinator) { FactoryBot.create(:user, :coordinator) }
  let(:analyst) { FactoryBot.create(:user, :analyst) }
  let(:guest) { FactoryBot.create(:user) }
  let(:manager) { FactoryBot.create(:user, :manager) }

  describe "Get index" do
    subject { get :index, format: :json }
    let!(:page) { FactoryBot.create(:page) }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end

    context "when signed in" do
      context "guest" do
        before { sign_in guest }

        it { expect(subject).to be_forbidden }
      end

      context "draft" do
        let!(:draft_page) { FactoryBot.create(:page, draft: true) }

        it "manager will see draft pages" do
          sign_in manager
          json = JSON.parse(subject.body)
          expect(json["data"].length).to eq(2)
        end

        it "coordinator will see draft pages" do
          sign_in coordinator
          json = JSON.parse(subject.body)
          expect(json["data"].length).to eq(2)
        end
      end

      context "private" do
        let!(:page) { FactoryBot.create(:page, :not_private) }
        let!(:private_page) { FactoryBot.create(:page, :private) }
        let!(:private_page_by_manager) { FactoryBot.create(:page, :private, created_by_id: manager.id) }
        let!(:private_page_by_coordinator) { FactoryBot.create(:page, :private, created_by_id: coordinator.id) }

        it "admin will see" do
          sign_in admin
          json = JSON.parse(subject.body)
          expect(json["data"].length).to eq(4)
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

        it "coordinator who created will see" do
          sign_in coordinator
          json = JSON.parse(subject.body)
          expect(json["data"].length).to eq(4)
        end

        it "coordinator who didn't create will not see" do
          sign_in FactoryBot.create(:user, :coordinator)
          json = JSON.parse(subject.body)
          expect(json["data"].length).to eq(4)
        end
      end
    end
  end

  describe "Get show" do
    let(:page) { FactoryBot.create(:page) }
    let(:draft_page) { FactoryBot.create(:page, draft: true) }
    subject { get :show, params: {id: page}, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }

      it "will not show draft page" do
        get :show, params: {id: draft_page}, format: :json
        expect(response).to be_forbidden
      end
    end

    context "when signed in" do
      let(:private_page_by_manager) { FactoryBot.create(:page, :private, created_by_id: manager.id) }
      let(:private_page) { FactoryBot.create(:page, :private) }
      let(:requested_resource) { page }
      subject { get :show, params: {id: requested_resource}, format: :json }

      context "as analyst" do
        context "will show page" do
          let(:requested_resource) { page }
          before { sign_in analyst }

          it { expect(subject).to be_ok }
        end

        context "will not show draft page" do
          let(:requested_resource) { draft_page }

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
            let(:requested_resource) { private_page_by_manager }

            it { expect(subject).to be_ok }
          end

          context "who didn't create won't see" do
            let(:requested_resource) { private_page }

            it { expect(subject).to be_not_found }
          end
        end
      end
    end
  end

  describe "Post create" do
    context "when not signed in" do
      it "not allow creating a page" do
        post :create, format: :json, params: {page: {title: "test", description: "test", target_date: "today"}}
        expect(response).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:taxonomy) { FactoryBot.create(:taxonomy) }

      subject do
        post :create,
          format: :json,
          params: {
            page: {
              title: "test",
              content: "bla",
              menu_title: "test"
            }
          }
      end

      it "will not allow a guest to create a page" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will allow a manager to create a page" do
        sign_in manager
        expect(subject).to be_created
      end

      it "will not allow an admin to create a page" do
        sign_in admin
        expect(subject).to be_created
      end

      it "will record what manager created the page", versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in admin
        json = JSON.parse(subject.body)
        expect(json["data"]["attributes"]["updated_by_id"].to_i).to eq admin.id
      end

      it "will return an error if params are incorrect" do
        sign_in admin
        post :create, format: :json, params: {page: {description: "desc only", taxonomy_id: 999}}
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "PUT update" do
    let(:page) { FactoryBot.create(:page) }
    subject do
      put :update,
        format: :json,
        params: {id: page,
                 page: {title: "test update", description: "test update", target_date: "today update"}}
    end

    context "when not signed in" do
      it "not allow updating a page" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      it "will not allow a guest to update a page" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will allow a manager to update a page" do
        sign_in manager
        expect(subject).to be_ok
      end

      it "will allow an admin to update a page" do
        sign_in admin
        expect(subject).to be_ok
      end

      it "will reject an update where the last_updated_at is older than updated_at in the database" do
        sign_in admin
        page_get = get :show, params: {id: page}, format: :json
        json = JSON.parse(page_get.body)
        current_update_at = json["data"]["attributes"]["updated_at"]

        Timecop.travel(Time.new + 15.days) do
          subject = put :update,
            format: :json,
            params: {id: page,
                     page: {title: "test update", description: "test updateeee", target_date: "today update", updated_at: current_update_at}}
          expect(subject).to be_ok
        end
        Timecop.travel(Time.new + 5.days) do
          subject = put :update,
            format: :json,
            params: {id: page,
                     page: {title: "test update", description: "test updatebbbb", target_date: "today update", updated_at: current_update_at}}
          expect(subject).to_not be_ok
        end
      end

      it "will record what manager updated the page", versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in admin
        json = JSON.parse(subject.body)
        expect(json["data"]["attributes"]["updated_by_id"].to_i).to eq admin.id
      end

      it "will return the latest updated_by", versioning: true do
        expect(PaperTrail).to be_enabled
        page.versions.first.update_column(:whodunnit, manager.id)
        sign_in admin
        json = JSON.parse(subject.body)
        expect(json["data"]["attributes"]["updated_by_id"].to_i).to eq(admin.id)
      end
    end
  end

  describe "Delete destroy" do
    let(:page) { FactoryBot.create(:page) }
    subject { delete :destroy, format: :json, params: {id: page} }

    context "when not signed in" do
      it "not allow deleting a page" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      it "will not allow a guest to delete a page" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will allow a manager to delete a page" do
        sign_in manager
        expect(subject).to be_no_content
      end

      it "will allow an admin to delete a page" do
        sign_in admin
        expect(subject).to be_no_content
      end
    end
  end
end
