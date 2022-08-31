require "rails_helper"

RSpec.describe UserMeasureMailer, type: :mailer do
  describe "task_updated" do
    let(:measure) { FactoryBot.create(:measure, :published) }
    let(:user_measure) { FactoryBot.create(:user_measure, measure: measure) }
    let(:mail) { UserMeasureMailer.task_updated(user_measure) }

    describe "with a standard measure" do
      let(:measure) { FactoryBot.create(:measure) }

      it "does not send an email" do
        expect(mail.body).to be_blank
        expect(mail.from).to be_nil
        expect(mail.subject).to be_nil
        expect(mail.to).to be_nil
      end
    end

    context "with a task measure" do
      before { allow(measure).to receive(:task?).and_return(true) }

      it "renders the headers" do
        expect(mail.subject).to eq(I18n.t("user_measure_mailer.task_updated.subject"))
        expect(mail.to).to eq([user_measure.user.email])
        expect(mail.from).to eq(%w[plasticpolicy@wwf.no])
      end

      it "mentions the user's name" do
        expect(mail.body.encoded).to match(user_measure.user.name)
      end

      it "mentions the measure title" do
        expect(mail.body.encoded).to match(user_measure.measure.title)
      end

      describe "that is draft" do
        let(:measure) { FactoryBot.create(:measure, :draft) }

        it "does not send an email" do
          expect(mail.body).to be_blank
          expect(mail.from).to be_nil
          expect(mail.subject).to be_nil
          expect(mail.to).to be_nil
        end
      end

      describe "that has notifications disabled" do
        let(:measure) { FactoryBot.create(:measure, notifications: false) }

        it "does not send an email" do
          expect(mail.body).to be_blank
          expect(mail.from).to be_nil
          expect(mail.subject).to be_nil
          expect(mail.to).to be_nil
        end
      end
    end
  end
end
