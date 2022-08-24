class UserMeasureMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_measure_mailer.created.subject
  #
  def created(user_measure)
    return if user_measure.measure.draft?

    @name = user_measure.user.name
    @title = user_measure.measure.title

    mail to: user_measure.user.email, subject: I18n.t("user_measure_mailer.created.subject")
  end
end
