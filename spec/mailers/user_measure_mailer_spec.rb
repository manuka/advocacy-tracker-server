require "rails_helper"

RSpec.describe UserMeasureMailer, type: :mailer do
  describe "task_updated" do
    let(:measure) { FactoryBot.create(:measure, :published) }
    let(:user_measure) { FactoryBot.create(:user_measure, measure: measure) }
    let(:mail) { UserMeasureMailer.task_updated(user_measure) }

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
  end
end
