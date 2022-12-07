require "rails_helper"
require "json"

RSpec.describe DueDatesController, type: :controller do
  let(:coordinator) { FactoryBot.create(:user, :coordinator) }

  describe "Get index" do
    subject { get :index, format: :json }
    let!(:due_date) { FactoryBot.create(:due_date) }
    let!(:draft_due_date) { FactoryBot.create(:due_date, draft: true) }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:user) { FactoryBot.create(:user, :manager) }

      it "guest will be forbidden" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "manager will see all due_dates" do
        sign_in user
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(2)
      end

      it "coordinator will see all due_dates" do
        sign_in coordinator
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(2)
      end
    end
  end

  describe "Get show" do
    let(:due_date) { FactoryBot.create(:due_date) }
    let(:draft_due_date) { FactoryBot.create(:due_date, draft: true) }
    subject { get :show, params: {id: due_date}, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_not_found }

      it "will not show draft due_date" do
        get :show, params: {id: draft_due_date}, format: :json
        expect(response).to be_not_found
      end
    end
  end

  describe "Post create" do
    context "when not signed in" do
      it "not allow creating a due_date" do
        post :create, format: :json, params: {due_date: {due_date: Time.zone.today.to_s}}
        expect(response).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:user) { FactoryBot.create(:user, :manager) }
      let(:indicator) { FactoryBot.create(:indicator) }

      subject do
        post :create,
          format: :json,
          params: {
            due_date: {
              due_date: Time.zone.today.to_s,
              indicator_id: indicator.id
            }
          }
      end

      it "will not allow a guest to create a due_date" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow a manager to create a due_date" do
        sign_in user
        expect(subject).to be_forbidden
      end

      it "will not allow a coordinator to create a due_date" do
        sign_in coordinator
        expect(subject).to be_forbidden
      end
    end
  end

  describe "PUT update" do
    let(:due_date) { FactoryBot.create(:due_date) }
    subject do
      put :update,
        format: :json,
        params: {id: due_date,
                 due_date: {due_date: 1.year.ago.to_s}}
    end

    context "when not signed in" do
      it "not allow updating a due_date" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:user) { FactoryBot.create(:user, :manager) }

      it "will not allow a guest to update a due_date" do
        sign_in guest
        expect(subject).to be_not_found
      end

      it "will not allow a manager to update a due_date" do
        sign_in user
        expect(subject).to be_forbidden
      end

      it "will not allow a coordinator to update a due_date" do
        sign_in coordinator
        expect(subject).to be_forbidden
      end
    end
  end

  describe "Delete destroy" do
    let(:due_date) { FactoryBot.create(:due_date) }
    subject { delete :destroy, format: :json, params: {id: due_date} }

    context "when not signed in" do
      it "not allow deleting a due_date" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:user) { FactoryBot.create(:user, :manager) }

      it "will not allow a guest to delete a due_date" do
        sign_in guest
        expect(subject).to be_not_found
      end

      it "will not allow a manager to delete a due_date" do
        sign_in user
        expect(subject).to be_forbidden
      end

      it "will not allow a coordinator to delete a due_date" do
        sign_in coordinator
        expect(subject).to be_forbidden
      end
    end
  end
end
