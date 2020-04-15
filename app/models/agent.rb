# frozen_string_literal: true

# == Schema Information
#
# Table name: agents
#
#  id         :bigint(8)        not null, primary key
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  player_id  :string
#  session_id :string           not null
#
class Agent < ApplicationRecord

  has_many :email_addresses, optional: true
  has_many :messages, through: :email_addresses

  after_create :claim_email

  def email
    last_email = email_addresses.last
    last_email.read_only? ? claim_email : last_email
  end

  private

    def claim_email
      EmailAddress.claim_for!(id)
    end
end
