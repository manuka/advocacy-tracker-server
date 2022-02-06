require "rails_helper"

RSpec.describe UsersController, type: :controller do
  describe "Get index" do
    subject { get :index, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_unauthorized }
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:manager2) { FactoryBot.create(:user, :manager) }
      let(:admin) { FactoryBot.create(:user, :admin) }
      let(:admin2) { FactoryBot.create(:user, :admin) }

      it "shows only themselves for guests" do
        manager
        admin
        sign_in guest
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(1)
        expect(json["data"][0]["id"]).to eq(guest.id.to_s)
      end

      it "shows all users for managers" do
        manager
        manager2
        admin
        admin2
        guest
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(5)
      end

      it "shows all users for admin" do
        manager
        manager2
        admin2
        guest
        sign_in admin
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(5)
      end
    end
  end

  describe "Get show" do
    let(:user_role) { FactoryBot.create(:user_role) }
    subject { get :show, params: {id: user_role}, format: :json }

    context "when not signed in" do
      it "does not show the user_role" do
        expect(subject).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:analyst) { FactoryBot.create(:user, :analyst) }
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:admin) { FactoryBot.create(:user, :admin) }

      subject { get :show, params: {id: manager.id}, format: :json }

      it "shows no user for guest" do
        sign_in guest
        expect(subject).to be_not_found
      end

      it "shows guest their own record" do
        sign_in guest
        subject_guest = get(:show, params: {id: guest.id}, format: :json)
        json = JSON.parse(subject_guest.body)
        expect(json.dig("data", "id").to_i).to eq(guest.id)
      end

      it "shows analyst their own record" do
        sign_in analyst
        subject_analyst = get(:show, params: {id: analyst.id}, format: :json)
        json = JSON.parse(subject_analyst.body)
        expect(json.dig("data", "id").to_i).to eq(analyst.id)
      end

      it "shows user for manager" do
        sign_in manager
        subject_manager = get :show, params: {id: manager.id}, format: :json
        json = JSON.parse(subject_manager.body)
        expect(json.dig("data", "id").to_i).to eq(manager.id)
      end

      it "shows user for admin" do
        sign_in admin
        subject_manager = get :show, params: {id: admin.id}, format: :json
        json = JSON.parse(subject_manager.body)
        expect(json.dig("data", "id").to_i).to eq(admin.id)
      end
    end
  end

  describe "POST create" do
    subject do
      post :create,
        format: :json,
        params: {user: {email: "test@co.nz", password: "testtest", name: "Sam"}}
    end

    context "when not signed in" do
      it "will allow a user to be created (registration)" do
        expect(subject).to have_http_status(201)
      end
    end
  end

  describe "PUT update" do
    let(:guest) { FactoryBot.create(:user) }
    let(:manager) { FactoryBot.create(:user, :manager) }
    let(:admin) { FactoryBot.create(:user, :admin) }
    subject do
      put :update,
        format: :json,
        params: {id: manager.id, user: {email: "test@co.nz", password: "testtest", name: "Sam"}}
    end

    context "when not signed in" do
      it "not allow updating a user" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:analyst) { FactoryBot.create(:user, :analyst) }
      let(:guest) { FactoryBot.create(:user) }
      let(:guest2) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:manager2) { FactoryBot.create(:user, :manager) }
      let(:admin) { FactoryBot.create(:user, :admin) }

      it "will not allow a user to update another user" do
        sign_in guest
        expect(subject).to be_not_found
      end

      it "will allow a guest to update themselves" do
        sign_in guest
        subject = put(:update,
          format: :json,
          params: {id: guest.id, user: {email: "test@co.nz", password: "testtest", name: "Sam"}})
        expect(subject).to be_ok
        json = JSON.parse(subject.body)
        expect(json.dig("data", "id").to_i).to eq(guest.id)
        expect(json.dig("data", "attributes", "email")).to eq "test@co.nz"
        expect(json.dig("data", "attributes", "name")).to eq "Sam"
      end

      it "will not allow a guest to update another user" do
        sign_in guest
        subject2 = put :update,
          format: :json,
          params: {id: guest2.id, user: {email: "test@co.guest.nz", password: "testtest", name: "Sam"}}
        expect(subject2).to be_not_found
      end

      it "will allow an analyst to update themselves" do
        sign_in analyst
        subject = put(:update,
          format: :json,
          params: {id: analyst.id, user: {email: "test@co.nz", password: "testtest", name: "Sam"}})
        expect(subject).to be_ok
        json = JSON.parse(subject.body)
        expect(json.dig("data", "id").to_i).to eq(analyst.id)
        expect(json.dig("data", "attributes", "email")).to eq "test@co.nz"
        expect(json.dig("data", "attributes", "name")).to eq "Sam"
      end

      it "will not allow an analyst to update another user" do
        sign_in analyst
        subject2 = put :update,
          format: :json,
          params: {id: guest.id, user: {email: "test@co.guest.nz", password: "testtest", name: "Sam"}}
        expect(subject2).to be_not_found
      end

      it "will allow a manager to update themselves" do
        sign_in manager
        expect(subject).to be_ok
        json = JSON.parse(subject.body)
        expect(json.dig("data", "id").to_i).to eq(manager.id)
        expect(json.dig("data", "attributes", "email")).to eq "test@co.nz"
        expect(json.dig("data", "attributes", "name")).to eq "Sam"
      end

      it "will not allow a manager to update another manager or admin" do
        sign_in manager
        manager_update = put :update,
          format: :json,
          params: {id: manager2.id, user: {email: "test@co.guest.nz", password: "testtest", name: "Sam"}}
        expect(manager_update).to be_forbidden
        admin_update = put :update,
          format: :json,
          params: {id: admin.id, user: {email: "test@co.guest.nz", password: "testtest", name: "Sam"}}
        expect(admin_update).to be_forbidden
        analyst_update = put :update,
          format: :json,
          params: {id: analyst.id, user: {email: "test@co.guest.nz", password: "testtest", name: "Sam"}}
        expect(analyst_update).to be_forbidden
        guest_update = put :update,
          format: :json,
          params: {id: guest.id, user: {email: "test@co.guest.nz", password: "testtest", name: "Sam"}}
        expect(guest_update).to be_forbidden
      end

      it "will allow an admin to update any user" do
        sign_in admin
        expect(subject).to be_ok
        json = JSON.parse(subject.body)
        expect(json.dig("data", "id").to_i).to eq(manager.id)
        expect(json.dig("data", "attributes", "email")).to eq "test@co.nz"
        expect(json.dig("data", "attributes", "name")).to eq "Sam"
      end

      it "will record what manager updated the user", versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in admin
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "updated_by_id").to_i).to eq admin.id
      end
    end
  end

  describe "Delete destroy" do
    let(:guest) { FactoryBot.create(:user) }
    let(:manager_role) { FactoryBot.create(:role, :manager) }
    let(:manager) { FactoryBot.create(:user, roles: [manager_role]) }
    let(:admin_role) { FactoryBot.create(:role, :admin) }
    let(:admin) { FactoryBot.create(:user, roles: [admin_role]) }

    subject { delete :destroy, format: :json, params: {id: guest} }

    context "when not signed in" do
      it "not allow deleting a user_role" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      it "will not allow a user to delete another user" do
        sign_in guest
        subject = delete :destroy, format: :json, params: {id: manager.id}
        expect(subject).to be_not_found
      end

      it "will not allow a user to delete themselves" do
        sign_in manager
        subject = delete :destroy, format: :json, params: {id: manager.id}
        expect(subject).to be_forbidden
      end

      it "will not allow an admin to delete another user" do
        sign_in admin
        subject = delete :destroy, format: :json, params: {id: manager.id}
        expect(subject).to be_forbidden
      end
    end
  end
end
