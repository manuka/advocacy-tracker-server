require "rails_helper"
require "json"

RSpec.describe UserRolesController, type: :controller do
  describe "Get index" do
    subject { get :index, format: :json }

    context "when not signed in" do
      it "is expected to be forbidden" do
        expect(subject).to be_forbidden
      end
    end

    context "when signed in" do
      let(:analyst) { FactoryBot.create(:user, :analyst) }
      let(:guest) { FactoryBot.create(:user) }
      let(:manager_role) { FactoryBot.create(:role, :manager) }
      let(:manager) { FactoryBot.create(:user, roles: [manager_role]) }
      let(:manager2) { FactoryBot.create(:user, roles: [manager_role]) }
      let(:admin_role) { FactoryBot.create(:role, :admin) }
      let(:admin) { FactoryBot.create(:user, roles: [admin_role]) }
      let(:admin2) { FactoryBot.create(:user, roles: [admin_role]) }

      it "does not show anything to guest user" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "shows all user roles for analysts" do
        manager
        manager2
        admin
        admin2
        sign_in analyst
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(5)
        returned_roles = json["data"].map { |user_role| user_role["attributes"]["role_id"] }.uniq
        permitted_roles = [manager.roles.first.id]
        expect(permitted_roles - returned_roles).to be_empty
      end

      it "shows all user roles for managers" do
        analyst
        manager
        manager2
        admin
        admin2
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(5)
        returned_roles = json["data"].map { |user_role| user_role["attributes"]["role_id"] }.uniq
        permitted_roles = [manager.roles.first.id]
        expect(permitted_roles - returned_roles).to be_empty
      end

      it "shows all user roles for admin" do
        analyst
        manager
        manager2
        admin2
        sign_in admin
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(5)
        returned_roles = json["data"].map { |user_role| user_role["attributes"]["role_id"] }.uniq
        permitted_roles = [manager.roles.first.id]
        expect(permitted_roles - returned_roles).to be_empty
      end
    end
  end

  describe "Get show" do
    let(:user_role) { FactoryBot.create(:user_role) }
    subject { get :show, params: {id: user_role}, format: :json }

    context "when not signed in" do
      it "does not show the user_role" do
        expect(subject).to be_not_found
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:admin) { FactoryBot.create(:user, :admin) }

      subject { get :show, params: {id: manager.user_roles.first.id}, format: :json }

      it "shows no user_role for guest" do
        sign_in guest
        expect(subject).to be_not_found
      end

      it "shows user_role for manager" do
        sign_in manager
        subject_manager = get :show, params: {id: manager.user_roles.first.id}, format: :json
        json = JSON.parse(subject_manager.body)
        expect(json.dig("data", "id").to_i).to eq(manager.user_roles.first.id)
      end

      it "shows user_role for admin" do
        sign_in admin
        subject_manager = get :show, params: {id: admin.user_roles.first.id}, format: :json
        json = JSON.parse(subject_manager.body)
        expect(json.dig("data", "id").to_i).to eq(admin.user_roles.first.id)
      end
    end
  end

  describe "Post create" do
    context "when not signed in" do
      it "not allow creating a user_role" do
        post :create, format: :json, params: {user_role: {user_id: 1, role_id: 1}}
        expect(response).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:manager_role) { FactoryBot.create(:role, :manager) }
      let(:manager) { FactoryBot.create(:user, roles: [manager_role]) }
      let(:admin_role) { FactoryBot.create(:role, :admin) }
      let(:admin) { FactoryBot.create(:user, roles: [admin_role]) }

      subject do
        post :create,
          format: :json,
          params: {
            user_role: {
              user_id: guest.id,
              role_id: manager.id
            }
          }
      end

      it "will not allow a guest to create a user_role" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow a manager to create a manager or admin user_role" do
        sign_in manager

        expect(post(:create,
          format: :json,
          params: {
            user_role: {
              user_id: guest.id,
              role_id: manager_role.id
            }
          })).to be_forbidden

        expect(
          post(:create,
            format: :json,
            params: {
              user_role: {
                user_id: guest.id,
                role_id: admin_role.id
              }
            })
        ).to be_forbidden
      end

      it "will allow an admin to create a manager, or admin admin user_role" do
        sign_in admin
        subject = post :create,
          format: :json,
          params: {
            user_role: {
              user_id: guest.id,
              role_id: manager_role.id
            }
          }
        expect(subject).to be_created

        subject = post :create,
          format: :json,
          params: {
            user_role: {
              user_id: manager.id,
              role_id: admin_role.id
            }
          }
        expect(subject).to be_created
      end

      it "will return an error if params are incorrect" do
        sign_in admin
        post :create, format: :json, params: {user_role: {description: "desc only", taxonomy_id: 999}}
        expect(response).to have_http_status(422)
      end

      it "will record what admin created the user role", versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in admin
        subject = post :create,
          format: :json,
          params: {
            user_role: {
              user_id: manager.id,
              role_id: admin_role.id
            }
          }
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "updated_by_id").to_i).to eq admin.id
      end
    end
  end

  describe "Delete destroy" do
    let(:guest) { FactoryBot.create(:user) }
    let(:manager_role) { FactoryBot.create(:role, :manager) }
    let(:manager) { FactoryBot.create(:user, roles: [manager_role]) }
    let(:manager_role2) { FactoryBot.create(:role, :manager) }
    let(:manager2) { FactoryBot.create(:user, roles: [manager_role2]) }
    let(:admin_role) { FactoryBot.create(:role, :admin) }
    let(:admin) { FactoryBot.create(:user, roles: [admin_role, manager_role]) }

    subject { delete :destroy, format: :json, params: {id: manager.user_roles.first} }

    context "when not signed in" do
      it "not allow deleting a user_role" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      it "will not allow a guest to delete a user_role" do
        sign_in guest
        expect(subject).to be_not_found
      end

      it "will not allow a manager to delete an admin or another manager" do
        sign_in manager

        subject = delete :destroy, format: :json, params: {id: manager2.user_roles.find_by(role_id: manager_role2.id)}
        expect(subject).to be_forbidden
        subject = delete :destroy, format: :json, params: {id: admin.user_roles.find_by(role_id: manager_role.id)}
        expect(subject).to be_forbidden
      end

      it "will allow an admin to delete a manager, and admin user_role" do
        sign_in admin
        subject = delete :destroy, format: :json, params: {id: manager.user_roles.first}
        expect(subject).to be_no_content
        subject = delete :destroy, format: :json, params: {id: admin.user_roles.first}
        expect(subject).to be_no_content
      end
    end
  end
end
