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

  # act_as_paranoid

  validates :session_id, presence: true
  validates :session_id, uniqueness: true, if: [:session_id_changed?, :session_id?]

  after_create :claim_email

  private

    def claim_email
      EmailAddress.claim_for!(id)
    end
end
