require "rails_helper"
require "json"

RSpec.describe MembershipsController, type: :controller do
  let(:analyst) { FactoryBot.create(:user, :analyst) }
  let(:coordinator) { FactoryBot.create(:user, :coordinator) }
  let(:guest) { FactoryBot.create(:user) }
  let(:manager) { FactoryBot.create(:user, :manager) }
  let(:member) { FactoryBot.create(:actor) }
  let(:memberof) { FactoryBot.create(:actor, actortype: FactoryBot.create(:actortype, :with_members)) }

  describe "Get index" do
    subject { get :index, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end
  end

  describe "Get show" do
    let(:membership) { FactoryBot.create(:membership, member: member, memberof: memberof) }
    subject { get :show, params: {id: membership}, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end
  end

  describe "Post create" do
    context "when not signed in" do
      it "not allow creating a membership" do
        post :create, format: :json, params: {membership: {memberof_id: 1, member_id: 1}}
        expect(response).to be_unauthorized
      end
    end

    context "when signed in" do
      subject do
        post :create,
          format: :json,
          params: {
            membership: {
              memberof_id: memberof.id,
              member_id: member.id
            }
          }
      end

      it "will not allow a guest to create a membership" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow an analyst to create a membership" do
        sign_in analyst
        expect(subject).to be_forbidden
      end

      it "will allow a manager to create a membership" do
        sign_in manager
        expect(subject).to be_created
      end

      it "will allow a coordinator to create a membership" do
        sign_in coordinator
        expect(subject).to be_created
      end

      it "will return an error if params are incorrect" do
        sign_in manager
        post :create, format: :json, params: {membership: {description: "desc only", taxonomy_id: 999}}
        expect(response).to have_http_status(422)
      end

      it "will record what manager created the membership", versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "updated_by_id").to_i).to eq manager.id
      end
    end
  end

  describe "Delete destroy" do
    let(:membership) { FactoryBot.create(:membership, member: member, memberof: memberof) }
    subject { delete :destroy, format: :json, params: {id: membership} }

    context "when not signed in" do
      it "not allow deleting a membership" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      it "will not allow a guest to delete a membership" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow an analyst to delete a membership" do
        sign_in analyst
        expect(subject).to be_forbidden
      end

      it "will allow a manager to delete a membership" do
        sign_in manager
        expect(subject).to be_no_content
      end

      it "will allow a coordinator to delete a membership" do
        sign_in coordinator
        expect(subject).to be_no_content
      end
    end
  end
end
