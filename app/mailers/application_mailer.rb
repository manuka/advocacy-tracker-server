# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "plasticpolicy@wwf.no"
  layout "mailer"
end
