# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "Global Plastic Policy Team <plasticpolicy@wwf.no>",
          return_path: "Global Plastic Policy Team <no-reply-plasticpolicy@wwf.no>"
  layout "mailer"
end
