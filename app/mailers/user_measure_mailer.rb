class UserMeasureMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_measure_mailer.created.subject
  #
  def created(user_measure)
    return unless user_measure.notify?

    @measure_id = user_measure.measure_id
    @name = user_measure.user.name
    @title = user_measure.measure.title
    @type = user_measure.measure.measuretype.title.downcase

    mail to: user_measure.user.email, subject: I18n.t("user_measure_mailer.created.subject", measuretype: @type)
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_measure_mailer.published.subject
  #
  def published(user_measure)
    return unless user_measure.notify?

    @measure_id = user_measure.measure_id
    @name = user_measure.user.name
    @title = user_measure.measure.title
    @type = user_measure.measure.measuretype.title.downcase

    mail to: user_measure.user.email, subject: I18n.t("user_measure_mailer.published.subject", measuretype: @type)
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_measure_mailer.task_updated.subject
  #
  def task_updated(user_measure)
    @measure_id = user_measure.measure_id
    @name = user_measure.user.name
    @title = user_measure.measure.title

    mail to: user_measure.user.email, subject: I18n.t("user_measure_mailer.task_updated.subject")
  end
end
