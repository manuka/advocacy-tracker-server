# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "plasticpolicy@dumpark.com"
  layout "mailer"
end
