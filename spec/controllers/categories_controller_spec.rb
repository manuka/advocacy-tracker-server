require "rails_helper"
require "json"

RSpec.describe CategoriesController, type: :controller do
  let(:admin) { FactoryBot.create(:user, :admin) }
  let(:analyst) { FactoryBot.create(:user, :analyst) }
  let(:coordinator) { FactoryBot.create(:user, :coordinator) }
  let(:guest) { FactoryBot.create(:user) }
  let(:manager) { FactoryBot.create(:user, :manager) }
  let(:taxonomy) { FactoryBot.create(:taxonomy) }

  describe "Get index" do
    subject { get :index, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end

    context "when signed in" do
      context "draft" do
        let!(:category) { FactoryBot.create(:category) }
        let!(:draft_category) { FactoryBot.create(:category, draft: true) }

        it "guest will be forbidden" do
          sign_in guest
          expect(subject).to be_forbidden
        end

        it "analyst will see non-draft categories" do
          sign_in analyst
          json = JSON.parse(subject.body)
          expect(json["data"].length).to eq(1)
        end

        it "manager will see draft categories" do
          sign_in manager
          json = JSON.parse(subject.body)
          expect(json["data"].length).to eq(2)
        end
      end

      context "is_archive categories" do
        let!(:category) { FactoryBot.create(:category, :not_is_archive) }
        let!(:is_archive_category) { FactoryBot.create(:category, :is_archive) }

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
        let!(:category) { FactoryBot.create(:category, :not_private) }
        let!(:private_category) { FactoryBot.create(:category, :private) }
        let!(:private_category_by_manager) { FactoryBot.create(:category, :private, created_by_id: manager.id) }

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
    let(:category) { FactoryBot.create(:category) }
    let(:private_category) { FactoryBot.create(:category, :private) }
    let(:private_category_by_coordinator) { FactoryBot.create(:category, :private, created_by_id: coordinator.id) }
    let(:private_category_by_manager) { FactoryBot.create(:category, :private, created_by_id: manager.id) }
    let(:requested_resource) { category }

    subject { get :show, params: {id: requested_resource}, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end

    context "when signed in" do
      context "as admin" do
        before { sign_in admin }

        it { expect(subject).to be_ok }
      end

      context "as coordinator" do
        before { sign_in coordinator }

        it { expect(subject).to be_ok }

        context "who created will see" do
          let(:requested_resource) { private_category_by_coordinator }

          it { expect(subject).to be_ok }
        end

        context "who didn't create will see" do
          let(:requested_resource) { private_category }

          it { expect(subject).to be_ok }
        end
      end

      context "as manager" do
        before { sign_in manager }

        it { expect(subject).to be_ok }

        context "who created will see" do
          let(:requested_resource) { private_category_by_manager }

          it { expect(subject).to be_ok }
        end

        context "who didn't create won't see" do
          let(:requested_resource) { private_category }

          it { expect(subject).to be_not_found }
        end
      end
    end
  end

  describe "Post create" do
    context "when not signed in" do
      it "not allow creating a category" do
        post :create, format: :json, params: {category: {title: "test", description: "test", target_date: "today"}}
        expect(response).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:params) do
        {
          category: {
            title: "test",
            short_title: "bla",
            description: "test",
            target_date: "today",
            taxonomy_id: taxonomy.id
          }
        }
      end

      subject { post :create, format: :json, params: params }

      it "will not allow a guest to create a category" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will allow a manager to create a category" do
        sign_in manager
        expect(subject).to be_created
      end

      it "will allow a coordinator to create a category" do
        sign_in coordinator
        expect(subject).to be_created
      end

      context "is_archive" do
        let(:params) do
          {
            category: {
              title: "test",
              short_title: "bla",
              description: "test",
              target_date: "today",
              taxonomy_id: taxonomy.id,
              is_archive: true
            }
          }
        end

        it "can't be set by manager" do
          sign_in manager
          expect(subject).to be_created
          expect(JSON.parse(subject.body).dig("data", "attributes", "is_archive")).to eq false
        end

        it "can't be set by coordinator" do
          sign_in coordinator
          expect(subject).to be_created
          expect(JSON.parse(subject.body).dig("data", "attributes", "is_archive")).to eq false
        end

        it "can be set by admin" do
          sign_in admin
          expect(subject).to be_created
          expect(JSON.parse(subject.body).dig("data", "attributes", "is_archive")).to eq true
        end
      end

      it "will record what manager created the category", versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json["data"]["attributes"]["updated_by_id"].to_i).to eq manager.id
      end

      it "will return an error if params are incorrect" do
        sign_in manager
        post :create, format: :json, params: {category: {description: "desc only", taxonomy_id: 999}}
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "PUT update" do
    let(:category) { FactoryBot.create(:category) }
    subject do
      put :update,
        format: :json,
        params: {id: category,
                 category: {title: "test update", description: "test update", target_date: "today update"}}
    end

    context "when not signed in" do
      it "not allow updating a category" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      it "will not allow a guest to update a category" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow an analyst to update a category" do
        sign_in analyst
        expect(subject).to be_forbidden
      end

      it "will allow a coordinator to update a category" do
        sign_in coordinator
        expect(subject).to be_ok
      end

      it "will allow a manager to update a category" do
        sign_in manager
        expect(subject).to be_ok
      end

      context "is_archive" do
        subject do
          put :update, format: :json, params: {id: category, category: {is_archive: true}}
        end

        it "can't be set by coordinator" do
          sign_in coordinator
          expect(JSON.parse(subject.body).dig("data", "attributes", "is_archive")).to eq false
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
        category_get = get :show, params: {id: category}, format: :json
        json = JSON.parse(category_get.body)
        current_update_at = json["data"]["attributes"]["updated_at"]

        Timecop.travel(Time.new + 15.days) do
          subject = put :update,
            format: :json,
            params: {id: category,
                     category: {title: "test update", description: "test updateeee", target_date: "today update", updated_at: current_update_at}}
          expect(subject).to be_ok
        end
        Timecop.travel(Time.new + 5.days) do
          subject = put :update,
            format: :json,
            params: {id: category,
                     category: {title: "test update", description: "test updatebbbb", target_date: "today update", updated_at: current_update_at}}
          expect(subject).to_not be_ok
        end
      end

      it "will record what manager updated the category", versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json["data"]["attributes"]["updated_by_id"].to_i).to eq manager.id
      end

      it "will return the latest updated_by", versioning: true do
        expect(PaperTrail).to be_enabled
        category.versions.first.update_column(:whodunnit, guest.id)
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json["data"]["attributes"]["updated_by_id"].to_i).to eq(manager.id)
      end

      it "will return an error if params are incorrect" do
        sign_in manager
        put :update, format: :json, params: {id: category, category: {taxonomy_id: 999}}
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "Delete destroy" do
    let(:category) { FactoryBot.create(:category) }
    subject { delete :destroy, format: :json, params: {id: category} }

    context "when not signed in" do
      it "not allow deleting a category" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      it "will not allow a guest to delete a category" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow an analyst to delete a category" do
        sign_in analyst
        expect(subject).to be_forbidden
      end

      it "will allow a manager to delete a category" do
        sign_in manager
        expect(subject).to be_no_content
      end

      it "response with success when versioned", versioning: true do
        expect(PaperTrail).to be_enabled
        category.update_attribute(:title, "something else")
        sign_in manager
        expect(subject.response_code).to eq(204)
      end
    end
  end
end
