# frozen_string_literal: true
# == Schema Information
#
# Table name: messages
#
#  id               :bigint(8)        not null, primary key
#  bcc              :jsonb            is an Array
#  cc               :jsonb            is an Array
#  date             :string
#  deleted_at       :datetime
#  from             :jsonb            is an Array
#  in_reply_to      :string
#  internal_date    :string
#  reply_to         :jsonb            is an Array
#  rfc822           :text
#  rfc822_header    :text
#  rfc822_text      :text
#  sender           :jsonb            is an Array
#  seqno            :integer          not null
#  subject          :string
#  to               :jsonb            is an Array
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  email_address_id :bigint(8)
#  message_id       :string           not null
#
# Indexes
#
#  index_messages_on_email_address_id  (email_address_id)
#  index_messages_on_message_id        (message_id)
#
# Foreign Keys
#
#  fk_rails_...  (email_address_id => email_addresses.id)
#
class Message < ApplicationRecord
  belongs_to :email_address, optional: true

  scope :message_id, -> (message_id) { where message_id: message_id }

  acts_as_paranoid

  before_validation :set_email, if: :new_record?

  private

    def set_email
      emails = to + cc + bcc
      emails.select { |address| address && address['host'] == 'inboxizer.com' }.map { |address| "#{address['mailbox']}@#{address['host']}" }.uniq.each do |e|
        email_address = EmailAddress.find_by(email: e)
        next if email_address.blank?

        self.email_address = email_address
        break
      end
    end
end
