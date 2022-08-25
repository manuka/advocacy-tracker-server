require "rails_helper"
require "json"

RSpec.describe UserMeasuresController, type: :controller do
  describe "Get index" do
    subject { get :index, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end
  end

  describe "Get show" do
    let(:user_measure) { FactoryBot.create(:user_measure) }
    subject { get :show, params: {id: user_measure}, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_forbidden }
    end
  end

  describe "Post create" do
    context "when not signed in" do
      it "not allow creating a user_measure" do
        post :create, format: :json, params: {user_measure: {user_id: 1, measure_id: 1}}
        expect(response).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:user) { FactoryBot.create(:user) }
      let(:measure) { FactoryBot.create(:measure) }

      subject do
        post :create,
          format: :json,
          params: {
            user_measure: {
              user_id: user.id,
              measure_id: measure.id
            }
          }
      end

      it "will not allow a guest to create a user_measure" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will allow a manager to create a user_measure" do
        sign_in manager
        expect(subject).to be_created
      end

      context "with measure notifications disabled" do
        let(:measure) { FactoryBot.create(:measure, notifications: false) }

        it "will not send a notification email" do
          sign_in manager
          expect { subject }.not_to change { ActionMailer::Base.deliveries.count }
        end
      end

      context "with measure notifications enabled" do
        let(:measure) { FactoryBot.create(:measure, notifications: true) }

        context "when the user is the creator" do
          let(:user) { manager }

          it "will not send a notification email" do
            sign_in manager
            expect { subject }.not_to change { ActionMailer::Base.deliveries.count }
          end
        end

        context "when the user is not the creator" do
          it "will send a notification email to the user" do
            sign_in manager
            expect { subject }.to change { ActionMailer::Base.deliveries.count }
            expect(ActionMailer::Base.deliveries.last.to).to eq [user.email]
            expect(ActionMailer::Base.deliveries.last.subject).to eq I18n.t(:subject, scope: [:user_measure_mailer, :created])
          end
        end
      end

      it "will return an error if params are incorrect" do
        sign_in manager
        post :create, format: :json, params: {user_measure: {description: "desc only", taxonomy_id: 999}}
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "Delete destroy" do
    let(:user_measure) { FactoryBot.create(:user_measure) }
    subject { delete :destroy, format: :json, params: {id: user_measure} }

    context "when not signed in" do
      it "not allow deleting a user_measure" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:user) { FactoryBot.create(:user, :manager) }

      it "will not allow a guest to delete a user_measure" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will allow a manager to delete a user_measure" do
        sign_in user
        expect(subject).to be_no_content
      end
    end
  end
end
