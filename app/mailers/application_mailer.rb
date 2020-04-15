# frozen_string_literal: true
class ApplicationMailer < ActionMailer::Base
  default from: 'info@inboxizer.com'
  layout 'mailer'
end
