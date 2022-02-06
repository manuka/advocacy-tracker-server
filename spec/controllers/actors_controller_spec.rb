# frozen_string_literal: true

require "rails_helper"
require "json"

RSpec.describe ActorsController, type: :controller do
  let(:admin) { FactoryBot.create(:user, :manager) }
  let(:analyst) { FactoryBot.create(:user, :analyst) }
  let(:guest) { FactoryBot.create(:user) }
  let(:manager) { FactoryBot.create(:user, :manager) }

  describe "Get index" do
    subject { get :index, format: :json }
    let!(:actor) { FactoryBot.create(:actor, :not_draft) }
    let!(:draft_actor) { FactoryBot.create(:actor) }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end

    context "when signed in" do
      it "guest will be forbidden" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "admin will see draft actors" do
        sign_in admin
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(2)
      end

      it "manager will see draft actors" do
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(2)
      end

      it "analyst will not see draft actors" do
        sign_in analyst

        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(1)
      end
    end
  end

  describe "Get show" do
    let(:actor) { FactoryBot.create(:actor) }
    let(:draft_actor) { FactoryBot.create(:actor, draft: true) }
    subject { get :show, params: {id: actor}, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end

    context "when signed in" do
      before { sign_in admin }

      it { expect(subject).to be_ok }
    end
  end

  describe "Post create" do
    context "when not signed in" do
      it "not allow creating an actor" do
        post :create, format: :json, params: {actor: {title: "test", description: "test", target_date: "today"}}
        expect(response).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:recommendation) { FactoryBot.create(:recommendation) }
      let(:category) { FactoryBot.create(:category) }
      let(:actortype) { FactoryBot.create(:actortype) }

      subject do
        post :create,
          format: :json,
          params: {
            actor: {
              code: "test",
              title: "test",
              description: "test",
              actortype_id: actortype.id,
              target_date: "today"
            }
          }
      end

      it "will not allow a guest to create an actor" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow an analyst to create an actor" do
        sign_in analyst
        expect(subject).to be_forbidden
      end

      it "will allow a manager to create an actor" do
        sign_in manager
        expect(subject).to be_created
      end

      it "will allow an admin to create an actor" do
        sign_in admin
        expect(subject).to be_created
      end

      it "will record what manager created the actor", versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "updated_by_id").to_i).to eq manager.id
      end

      it "will return an error if params are incorrect" do
        sign_in manager
        post :create, format: :json, params: {actor: {description: "desc only"}}
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "PUT update" do
    let(:actor) { FactoryBot.create(:actor) }
    subject do
      put :update,
        format: :json,
        params: {id: actor,
                 actor: {title: "test update", description: "test update", target_date: "today update"}}
    end

    context "when not signed in" do
      it "not allow updating an actor" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      it "will not allow a guest to update an actor" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow an analyst to update an actor" do
        sign_in analyst
        expect(subject).to be_forbidden
      end

      it "will allow a manager to update an actor" do
        sign_in manager
        expect(subject).to be_ok
      end

      it "will allow an admin to update an actor" do
        sign_in admin
        expect(subject).to be_ok
      end

      it "will reject and update where the last_updated_at is older than updated_at in the database" do
        sign_in manager
        actor_get = get :show, params: {id: actor}, format: :json
        json = JSON.parse(actor_get.body)
        current_update_at = json["data"]["attributes"]["updated_at"]

        Timecop.travel(Time.new + 15.days) do
          subject = put :update,
            format: :json,
            params: {id: actor,
                     actor: {title: "test update", description: "test updateeee", target_date: "today update", updated_at: current_update_at}}
          expect(subject).to be_ok
        end
        Timecop.travel(Time.new + 5.days) do
          subject = put :update,
            format: :json,
            params: {id: actor,
                     actor: {title: "test update", description: "test updatebbbb", target_date: "today update", updated_at: current_update_at}}
          expect(subject).to_not be_ok
        end
      end

      it "will record what manager updated the actor", versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "updated_by_id").to_i).to eq manager.id
      end

      it "will return the latest updated_by", versioning: true do
        expect(PaperTrail).to be_enabled
        actor.versions.first.update_column(:whodunnit, admin.id)
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "updated_by_id").to_i).to eq(manager.id)
      end

      it "will return an error if params are incorrect" do
        sign_in manager
        put :update, format: :json, params: {id: actor, actor: {title: ""}}
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "Delete destroy" do
    let(:actor) { FactoryBot.create(:actor) }
    subject { delete :destroy, format: :json, params: {id: actor} }

    context "when not signed in" do
      it "not allow deleting an actor" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:user) { FactoryBot.create(:user, :manager) }

      it "will not allow a guest to delete an actor" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will allow a manager to delete an actor" do
        sign_in manager
        expect(subject).to be_no_content
      end
    end
  end
end
