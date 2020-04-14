# frozen_string_literal: true
# == Schema Information
#
# Table name: messages
#
#  id            :bigint(8)        not null, primary key
#  bcc           :jsonb            is an Array
#  cc            :jsonb            is an Array
#  date          :string
#  email         :string
#  from          :jsonb            is an Array
#  in_reply_to   :string
#  internal_date :string
#  reply_to      :jsonb            is an Array
#  rfc822        :text
#  rfc822_header :text
#  rfc822_text   :text
#  sender        :jsonb            is an Array
#  seqno         :integer          not null
#  subject       :string
#  to            :jsonb            is an Array
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  message_id    :string           not null
#
class Message < ApplicationRecord

  before_validation :set_email, if: :new_record?

  private

    def set_email
      (to + cc + bcc).select { |address| address && address['host'] == 'inboxizer.com' }.map { |address| "#{address['mailbox']}@#{address['host']}" }.uniq.each do |e|
        email_address = EmailAddress.find_by(email: e)
        next if email_address.blank?

        self.email = email_address.email
        break
      end
    end
end
