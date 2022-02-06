require "rails_helper"
require "json"

RSpec.describe CategoriesController, type: :controller do
  let(:analyst) { FactoryBot.create(:user, :analyst) }
  let(:guest) { FactoryBot.create(:user) }
  let(:manager) { FactoryBot.create(:user, :manager) }
  let(:taxonomy) { FactoryBot.create(:taxonomy) }

  describe "Get index" do
    let!(:category) { FactoryBot.create(:category) }
    let!(:draft_category) { FactoryBot.create(:category, draft: true) }
    subject { get :index, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end

    context "when signed in" do
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
  end

  describe "Get show" do
    let(:category) { FactoryBot.create(:category) }
    subject { get :show, params: {id: category}, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
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
      subject do
        post :create,
          format: :json,
          params: {
            category: {
              title: "test",
              short_title: "bla",
              description: "test",
              target_date: "today",
              taxonomy_id: taxonomy.id
            }
          }
      end

      it "will not allow a guest to create a category" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will allow a manager to create a category" do
        sign_in manager
        expect(subject).to be_created
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

      it "will allow a manager to update a category" do
        sign_in manager
        expect(subject).to be_ok
      end

      it "will reject and update where the last_updated_at is older than updated_at in the database" do
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
